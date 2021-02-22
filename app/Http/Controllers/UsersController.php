<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use App\Models\User;

use Validator;
class UsersController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
        return User::all();
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
            'name' => 'required',
            'email' => 'required|email',
            'password' => 'required',
            'scopes' =>'required|array',
            'creatorId' => 'required'
        ]);
        if($validator->fails()){
            return response()->json(['error' => $validator->errors()->all()]);
        }
        //$request['accessType']
        //
        $userData=[
            "name" => $request['name'],
            "email" => $request['email'],
            "password" => Hash::make($request['password'])
            ];
        $user=User::create($userData);

        foreach ($request->scopes as $key => $scopeName) {
            DB::Select("call  CreateScopeForUser(
                ".$user->id.",
                '".$scopeName."',
                ".$request->creatorId.")");
        }

        if($user)
         return response()->json(["message"=>"success"]);
        else
            return response()->json(["message"=>$user]);
    }
    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
        return User::whereId($id)->get();
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
        //
        $validator = Validator::make($request->all(), [
            'email' => 'email',
            'scopes' =>'array'
        ]);
        if($validator->fails()){
            return response()->json(['error' => $validator->errors()->all()]);
        }
        if($request->password)
        {
            $request->merge([
                'password' => Hash::make($request->password)
            ]);
        }
        $request->merge([
            'updated_at'=> date ('Y-m-d H:i:s', time())
        ]);
        //TODO-> update user scopes
        $success= User::whereId($id)->update($request->only([
            'name',
            'email',
            'password',
            'updated_at'
        ]));

        if($success)
            return response()->json(["message"=>$success]);
        else
            return response()->json(["message"=>"Error Updating User ".User::whereId($id)->get('id')]);
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
        //TODO revoke tokens
        return response()->json(["message"=>User::whereId($id)->delete()]);
    }

    /**
     * logout the specified authenticated user.
     *
     * @param  Request  $request
     * @return \Illuminate\Http\Response
     */
    public function logout(Request $request)
    {
        //
        $validator = Validator::make($request->all(), [
            'userId' => 'required'
        ]);
        if($validator->fails()){
            return response()->json(['error' => $validator->errors()->all()]);
        }
        //
        $success=DB::Select('call LogoutUser('.$request->userId.')');
        if($success===[])
            return response()->json(["message"=>"User logged out"]);
        else
            return response()->json(["message"=>"error"]);
    }
}
