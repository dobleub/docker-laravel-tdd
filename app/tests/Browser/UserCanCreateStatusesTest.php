<?php

namespace Tests\Browser;

use Tests\DuskTestCase;
use Laravel\Dusk\Browser;
use Illuminate\Foundation\Testing\DatabaseMigrations;

class UserCanCreateStatusesTest extends DuskTestCase
{
    /**
     * A Dusk test example.
     * @test
     * @return void
     */
    public function users_can_create_statuses()
    {
        $this->browse(function (Browser $browser) {
            $browser->visit('/')
                    ->type('body', 'Mi primer status')      // input type:body
                    ->press('#create-status')
                    ->assertSee('Mi primer status');
        });
    }
}
