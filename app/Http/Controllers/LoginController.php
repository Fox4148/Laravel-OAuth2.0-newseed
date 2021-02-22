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

    public function userDashboard()
    {

        $users = User::all();

        $success =  $users;


        return response()->json($success, 200);
    }

    public function customerDashboard()
    {
        $users = Customer::all();
        $success =  $users;
        return response()->json($success, 200);
    }

    public function userLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if($validator->fails()){
            return response()->json(['error' => $validator->errors()->all()]);
        }

        if(auth()->guard('user')->attempt(['email' => request('email'), 'password' => request('password')])){
            config(['auth.guards.api.provider' => 'user']);

            $user = User::select('users.*')->find(auth()->guard('user')->user()->id);

            $success =  $user;
            $tokenScopes = $this->GetUserScopes($user->id);
            $success['token'] =  $user->createToken($user->name.' token',$tokenScopes)->accessToken; 

            return response()->json($success, 200);

        }else{ 
            return response()->json(['error' => ['Email and Password are Wrong.']], 200);
        }

    }


    public function customerLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if($validator->fails()){
            return response()->json(['error' => $validator->errors()->all()]);
        }

        if(auth()->guard('customer')->attempt(['email' => request('email'), 'password' => request('password')])){
            config(['auth.guards.api.provider' => 'customer']);
  
            $customer = Customer::select('customers.*')->find(auth()->guard('customer')->user()->id);
            $success =  $customer;
            $success['token'] =  $customer->createToken('MyApp',['customer'])->accessToken; 

            return response()->json($success, 200);
        }else{ 
            return response()->json(['error' => ['Email and Password are Wrong.']], 200);
        }
    }    

    private function GetUserScopes($userId)
    {
        $dbScopes=DB::Select('call GetScopesFromUser('.$userId.')');
        $toReturn=[];
        foreach ($dbScopes as $key => $scope) 
            array_push($toReturn, $scope->name);
        array_push($toReturn,"user");
        return $toReturn;
    }

    private function GetCustomerScopes($customerId)
    {

    }

}