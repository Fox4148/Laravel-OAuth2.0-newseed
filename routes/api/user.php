<?php


use Illuminate\Http\Request;

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\LoginController;
use App\Http\Controllers\CustomersController;
use App\Http\Controllers\UsersController;

/*

|--------------------------------------------------------------------------

| API Routes

|--------------------------------------------------------------------------

|

| Here is where you can register API routes for your application. These

| routes are loaded by the RouteServiceProvider within a group which

| is assigned the "api" middleware group. Enjoy building your API!

|

*/


Route::post('user/login',[LoginController::class, 'userLogin'])->name('userLogin');

Route::group( ['prefix' => 'user','middleware' => ['auth:user-api','scopes:user'] ],function(){

	Route::post('create',[\App\Http\Controllers\UsersController::class, 'store'])->middleware(['scope:User_Create']);
	Route::get('/',[\App\Http\Controllers\UsersController::class, 'index'])->middleware(['scope:User_Read']);
	
	Route::post('logout',[\App\Http\Controllers\UsersController::class, 'logout'])->middleware(['scope:User_Update']);

	//
	Route::group(['prefix' =>'{id}'],function(){
		Route::get('/',[\App\Http\Controllers\UsersController::class, 'show'])->middleware(['scope:User_Read']);
		Route::post('/',[\App\Http\Controllers\UsersController::class, 'update'])->middleware(['scope:User_Update']);
		Route::post('delete',[\App\Http\Controllers\UsersController::class, 'destroy'])->middleware(['scope:User_Delete']);
	});

});   