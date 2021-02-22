<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;
use Laravel\Passport\Passport;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array
     */
    protected $policies = [
        // 'App\Models\Model' => 'App\Policies\ModelPolicy',
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();
        //passport registrations
         Passport::refreshTokensExpireIn(now()->addDays(1));
        Passport::personalAccessTokensExpireIn(now()->adddays(1));
        Passport::cookie(config('app.name'));
        Passport::routes();
        Passport::tokensCan([
            'user' => 'User Type',
            'User_Create' => 'Create User',
            'User_Read' => 'Read User',
            'User_Update' => 'Update User',
            'User_Delete' => 'Delete User',
        ]);

        //
    }
}
