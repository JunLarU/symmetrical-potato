<?php

namespace App\Controllers;

use Whis\Http\Response;

class TestController
{
    public function create()
    {
        

        return json([
            'success' => true,
            'numero_original' => 1,
            'resultado' => 1
        ]);
    }
}
