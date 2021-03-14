<?php


namespace App\Http\Controllers;


use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

use App\Models\User;

use App\Customer;

use Hash;

use Validator;

use Auth;


class LoginController extends Controller

{
    use \App\Models\Traits\HasPassportScopes;
    //
    public function userLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if($validator->fails()){
            return response()->json(['error' => $validator->errors()->all()]);
        }

        if(auth()->guard('user')->attempt(['email' => request('email'), 'password' => request('password')])){
            config(['auth.guards.api.provider' => 'user']);

            $user = User::select('users.*')->find(auth()->guard('user')->user()->id);
            $tokenScopes = $this->GetUserScopes($user->id,$user->name);
            $token =  $user->createToken($user->name,$tokenScopes)->accessToken; 

            $user->userInfo->increment('logon_count');
            return response()->json([
                'user'=>$user,
                'token'=>$token,
                'csrf'=>$request->session()->token()], 200);

        }else{ 
            return response()->json(['error' => ['Email and Password are Wrong.']], 200);
        }

    }

    public function userSignup(Request $request)
    {
        
    }

}

/*SELECT id FROM `oauth_access_tokens` WHERE (Select SUBSTRING_INDEX(name,';',1) from `oauth_access_tokens`
 Where user_id=19) ='1First.1Last@example.com'*/