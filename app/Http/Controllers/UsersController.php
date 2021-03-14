<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Models\UserInfo;
use App\Models\UserScope;

use Laravel\Passport\TokenRepository;
use Laravel\Passport\Passport;

use Validator;
use Auth;
class UsersController extends Controller
{
    use \App\Models\Traits\HasPassportScopes;
    //

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
        $users = User::all()->where('id','!=',Auth::guard('user')->user()->id);
        foreach ($users as $user) {
            $user->load('userInfo');
        }
        return response()->json($users->values(),200);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string',
            'email' => 'required|email|unique:users',
            'password' => 'sometimes|string|max:60',
            'scopes' =>'sometimes|array',
            'scopes.*'=>'sometimes|distinct|string|max:100',
            'creatorId' => 'required|numeric'
        ]);
        if($validator->fails()){
            return response()->json(['error' => $validator->errors()->all()]);
        }
        //
        $request->merge([
            'password'=>Hash::make($request->password)
        ]);
        //
        $user=User::create($request->except([
            'scopes',
            'creatorId'
        ]));
        //create the user Info
        UserInfo::create([
            'users_id'=>$user->id
        ]);
        //
        foreach ($request->scopes as $key => $scopeName) {
            DB::Select('call  CreateScopeForUser(?,?,?)',[
                $user->id,
                $scopeName,
                Auth::guard('user-api')->user()->id]);
        }
        //
        if($user)
         return response()->json(["message"=>"success"],200);
        else
            return response()->json(["message"=>$user],500);
    }
    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $user= User::find($id);

        $user->user_scope=UserScope::where('active',1)
            ->where('users_id',$user->id)
            ->join('scopes','scopes_id','scopes.id')->get('scopes.name');
        //
        return response()->json($user,200);
    }

    /**
     * Update the specified resource in storage.
     *
     * Must include all the scopes for the update to work
     * (send those alrealy in the database along with the new ones in the $request->scopes array)
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $httpResponse=[];
        //
        $validator = Validator::make($request->all(), [
            'name'=>'sometimes|string|max:255',
            'email' => 'sometimes|email|unique:users',
            'password' => 'sometimes|string|max:60',
            'scopes' =>'sometimes|array',
            'scopes.*'=>'sometimes|distinct|string|max:100'
        ]);
        if($validator->fails()){
            return response()->json(['error' => $validator->errors()->all()],500);
        }
        //
        $user= User::find($id);

        //password update
        if($request->password)
            $request->merge([
                'password' => Hash::make($request->password)
            ]);

        //check if scopes update is requested
        if($request->scopes)
            $this->updateScopes($request->scopes,$id,$user->name);

        //update the user
        $user->update($request->except(['scopes']));
        //
        return response()->json(["message"=>'success'],200);
    }

    /**
     * Update the user active scopes
     *     
     * @param  array $scopes : scopes to activate
     * @param  int  $id : User Id
     * @param  string  $name : User Name
     * @return \Illuminate\Http\Response
     */
    private function updateScopes($scopes,$id,$name)
    {
        try 
        {
            //revoke all tokens
            $tokens= Passport::token()->where(['user_id'=> $id,'name'=>$name])->get();
            foreach ($tokens as $key => $value) 
                app(TokenRepository::class)->revokeAccessToken($value->id);
            //
            //set all scopes alrealy set to inactive
            DB::Select('call ResetUserScopes(?)',[$id]);
            //reactivate the scopes present in $scopes
            foreach ($scopes as $key => $value) 
            DB::Select('call UpdateScopeForUser(?,?,?)',[
                $value,
                1,
                $id
            ]);

            //
            $activeScopes=UserScope::where('active',1)
                            ->where('users_id',$id)
                            ->join('scopes','scopes_id','scopes.id')->get('scopes.name');
            foreach ($scopes as $scope) 
            {
                $isRegistred=false;
                foreach ($activeScopes as $activeScope) 
                {
                    if($activeScope['name']==$scope)
                        $isRegistred=true;
                }
                //
                if(!$isRegistred)
                    DB::Select('call CreateScopeForUser(?,?,?)',[$id,$scope,Auth::guard('user-api')->user()->id
                    ]);
            }
            //
            return 1;
        } catch (Exception $e) {
            return 0;
        }
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
        $deletion = User::whereId($id)->delete();
        if($deletion)
            return response()->json(["message"=>"Success"],200);
        else
            return response()->json(["error"=>$deletion],500);
        //@TODO: revoke tokens
    }

    /**
     * logout the specified authenticated user.
     * Only authenticated user can access this route
     *
     * @param  Request  $request
     * @return \Illuminate\Http\Response
     */
    public function logout(Request $request)
    {
        //
        if(Auth::check())
        {
            $success=DB::Select('call Logout(?,?)',[Auth::user()->id,Auth::user()->name]);
            if($success===[])
            return response()->json(["message"=>"User logged out"],200);
        }
        else
            return response()->json(["message"=>"error"],501);
    }

    public function scope_name()
    {
        $scopeModel=\App\Models\Scope::class;
        $scopes=$scopeModel::all();
        return response()->json($scopes,200);
    }
}
