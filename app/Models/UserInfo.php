<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * @property integer $users_id
 * @property int $logon_count
 * @property string $created_at
 * @property string $updated_at
 * @property User $user
 */
class UserInfo extends Model
{
    /**
     * The table associated with the model.
     * 
     * @var string
     */
    protected $table = 'users_info';

    /**
     * The primary key for the model.
     * 
     * @var string
     */
    protected $primaryKey = 'users_id';

    /**
     * Indicates if the IDs are auto-incrementing.
     * 
     * @var bool
     */
    public $incrementing = false;

    /**
     * @var array
     */
    protected $fillable = [
        'users_id',
        'logon_count',
        'created_at', 
        'updated_at'
     ];

     protected $hidden=[
        'users_id',
        'created_at'
     ];

     protected $casts=[
        'updated_at'=> 'datetime:Y-m-d H:m'
     ];
    /**
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function user()
    {
        return $this->belongsTo('App\Models\User', 'users_id');
    }
}
