<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @property int $id
 * @property string $name
 * @property CustomersScope[] $customersScopes
 * @property UsersScope[] $usersScopes
 */
class Scope extends Model
{
    /**
     * @var array
     */
    protected $fillable = ['name'];

    protected $hidden=['id','pivot'];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\HasMany
     */
    public function userScope()
    {
        return $this->hasMany('App\Models\UserScope', 'scopes_id');
    }
}
