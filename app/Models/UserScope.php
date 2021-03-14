<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @property int $id
 * @property integer $users_id
 * @property int $scopes_id
 * @property integer $created_by
 * @property string $created_at
 * @property string $updated_at
 * @property boolean $active
 * @property Scope $scope
 * @property User $user
 * @property User $user
 */
class UserScope extends Model
{
    /**
     * The table associated with the model.
     * 
     * @var string
     */
    protected $table = 'users_scopes';
    
    protected $primaryKey = 'users_id';

    /**
     * @var array
     */
    protected $fillable = [
        'users_id', 
        'scopes_id', 
        'created_by',
        'created_at', 
        'updated_at', 
        'active'];

    protected $hidden=[
        'id',
        'scopes_id',
        'users_id',
        'created_by',
        'created_at', 
        'updated_at'
    ];

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function scope()
    {
        return $this->belongsTo('App\Models\Scope', 'scopes_id');
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function user()
    {
        return $this->belongsTo('App\Models\User', 'users_id');
    }

    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function creator()
    {
        return $this->belongsTo('App\Models\User', 'created_by');
    }
}
