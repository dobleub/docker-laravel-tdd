<?php

namespace Tests\Feature;

use App\User;
use Tests\TestCase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Foundation\Testing\RefreshDatabase;

class CreateStatusTest extends TestCase
{
    /**
     * A basic test example.
     *
     * @test
     */
    public function a_user_can_create_statuses()
    {
    	/* 1. Given - Teniendo un usuario authenticado */
    	$user = factory(User::class)->create();
    	$this->actingAs($user);
    	/* 2. When - Cuando hace un post request */
    	$this->post(route('status.store'), ['body'=>'Mi primer status']);
    	/* 3. Then - Entonces veo un nuevo estado en la DB */
        $this->assertDatabaseHas('statuses', [
        	'body' => 'Mi primer status'
        ]);
    }
}
