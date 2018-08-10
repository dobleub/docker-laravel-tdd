<?php

namespace Tests\Feature;

use App\User;
use Tests\TestCase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Foundation\Testing\RefreshDatabase;

class CreateStatusTest extends TestCase
{
	use RefreshDatabase;

	/**
     * @test
     */
	public function guest_users_cannot_create_statuses() {
    	// $this->withoutExceptionHandling();

		$response = $this->post(route('statuses.store'), ['body'=>'Mi primer status']);
		// dd($response->content());
		$response->assertRedirect('login');
	}

    /**
     * A basic test example.
     * @test
     */
    public function a_user_can_create_statuses() {
    	$this->withoutExceptionHandling();

    	/* 1. Given - Teniendo un usuario authenticado */
    	$user = factory(User::class)->create();
    	$this->actingAs($user);
    	/* 2. When - Cuando hace un post request */
    	$response = $this->post(route('statuses.store'), ['body'=>'Mi primer status']);
    	$response->assertJson([
    		'body' => 'Mi primer status'
    	]);
    	/* 3. Then - Entonces veo un nuevo estado en la DB */
        $this->assertDatabaseHas('statuses', [
        	'user_id' => $user->id,
        	'body' => 'Mi primer status'
        ]);
    }

    /**
     * @test
     */
    public function a_status_requires_a_body() {
    	// $this->withoutExceptionHandling();

    	$user = factory(User::class)->create();
    	$this->actingAs($user);
    	
    	$response = $this->postJson(route('statuses.store'), ['body'=>'']);

    	$response->assertStatus(422);

    	$response->assertJsonStructure([
    		'message', 'errors' => ['body']
    	]);
    }

    /**
     * @test
     */
    public function a_status_body_requires_a_minimun_length() {
    	// $this->withoutExceptionHandling();

    	$user = factory(User::class)->create();
    	$this->actingAs($user);
    	
    	$response = $this->postJson(route('statuses.store'), ['body'=>'asdf']);

    	$response->assertStatus(422);

    	$response->assertJsonStructure([
    		'message', 'errors' => ['body']
    	]);
    }
}
