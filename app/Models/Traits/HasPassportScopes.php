<?php

namespace App\Models\Traits;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

trait HasPassportScopes
{
	private function GetUserScopes($userId,$userName)
    {
        $dbScopes=DB::Select('call GetScopesForUser(?,?)',[$userId,$userName]);
        $toReturn=[];
        foreach ($dbScopes as $key => $scope) 
            array_push($toReturn, $scope->name);
        array_push($toReturn,"user");
        return $toReturn;
    }

    private function GetCustomerScopes($customerId,$customerEmail)
    {
        $dbScopes=DB::Select('call GetScopesForCustomer(?,?)',[$customerId,$customerEmail]);
        $toReturn=[];
        foreach ($dbScopes as $key => $scope) 
            array_push($toReturn, $scope->name);
        array_push($toReturn,"customer");
        return $toReturn;
    }
}