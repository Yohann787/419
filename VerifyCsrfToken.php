<?php

namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class VerifyCsrfToken extends Middleware
{
    protected $except = [
        // '/register',
    ];

    public function handle(Request $request, Closure $next)
    {
        Log::info('CSRF DEBUG', [
            'method' => $request->method(),
            'url' => $request->url(),
            'session_token' => $request->session()->token(),
            'input_token' => $request->input('_token'),
        ]);

        return parent::handle($request, $next);
    }
}
