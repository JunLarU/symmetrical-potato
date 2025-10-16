<?php

use Whis\Routing\Route;
use App\Models\UserModel;

Route::post('/api/users/signup', function () {
    header('Content-Type: application/json; charset=utf-8');

    // Leer cuerpo JSON
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);

    // Verificar formato JSON
    if (json_last_error() !== JSON_ERROR_NONE || empty($data)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'JSON inválido o cuerpo vacío'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // Campos requeridos
    $required = [
        'expediente',
        'nombre',
        'apellido_paterno',
        'apellido_materno',
        'correo',
        'telefono',
        'nip',
        'tipo'
    ];

    foreach ($required as $field) {
        if (!isset($data[$field]) || trim($data[$field]) === '') {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => "Falta el campo requerido: $field"
            ], JSON_UNESCAPED_UNICODE);
            return;
        }
    }

    // Validar correo
    if (!filter_var($data['correo'], FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Correo inválido'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // Verificar tipo de usuario solicitado
    $tipoSolicitado = ucfirst(strtolower(trim($data['tipo'])));

    // Si intenta crear un Administrador
    if ($tipoSolicitado === 'Administrador') {
        // Debe existir expediente_admin
        if (!isset($data['expediente_admin']) || trim($data['expediente_admin']) === '') {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'Solo un Administrador autenticado puede registrar a otro Administrador.'
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Verificar si el expediente_admin es válido y es un Admin activo
        $admin = UserModel::firstWhere('Expediente', strtoupper(trim($data['expediente_admin'])));

        if (!$admin || $admin->Tipo !== 'Administrador' || (int)$admin->Activo === 0) {
            http_response_code(403);
            echo json_encode([
                'success' => false,
                'message' => 'El expediente del administrador no es válido o no tiene permisos para registrar administradores.'
            ], JSON_UNESCAPED_UNICODE);
            return;
        }
    } else {
        // Si no se especificó expediente_admin, fuerza el tipo a Usuario
        $tipoSolicitado = 'Usuario';
    }

    // Verificar duplicados (Expediente o Correo)
    if (UserModel::firstWhere('Expediente', $data['expediente'])) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'El expediente ya está registrado'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    if (UserModel::firstWhere('Correo', $data['correo'])) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'El correo ya está registrado'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // Hashear NIP antes de guardar
    $hashedNip = password_hash($data['nip'], PASSWORD_BCRYPT);

    try {
        // Crear el nuevo usuario
        UserModel::create([
            'Expediente'      => strtoupper(trim($data['expediente'])),
            'Nombre'          => ucwords(trim($data['nombre'])),
            'ApellidoPaterno' => ucwords(trim($data['apellido_paterno'])),
            'ApellidoMaterno' => ucwords(trim($data['apellido_materno'])),
            'Correo'          => strtolower(trim($data['correo'])),
            'Telefono'        => trim($data['telefono']),
            'NIP'             => $hashedNip,
            'Tipo'            => $tipoSolicitado,
            'Activo'          => 1
        ]);

        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => "Usuario registrado correctamente como $tipoSolicitado",
            'usuario' => [
                'Expediente'      => $data['expediente'],
                'Nombre'          => $data['nombre'],
                'ApellidoPaterno' => $data['apellido_paterno'],
                'ApellidoMaterno' => $data['apellido_materno'],
                'Correo'          => $data['correo'],
                'Telefono'        => $data['telefono'],
                'Tipo'            => $tipoSolicitado
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (Throwable $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error interno al registrar el usuario',
            'error'   => $e->getMessage()
        ], JSON_UNESCAPED_UNICODE);
    }
});

Route::post('/api/users/login', function () {
    header('Content-Type: application/json; charset=utf-8');

    // Leer cuerpo JSON
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);

    // Validar JSON
    if (json_last_error() !== JSON_ERROR_NONE || empty($data)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'JSON inválido o cuerpo vacío'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // Verificar campos requeridos
    if (!isset($data['expediente']) || trim($data['expediente']) === '' ||
        !isset($data['nip']) || trim($data['nip']) === '') {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Faltan campos requeridos: expediente o nip'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    $expediente = strtoupper(trim($data['expediente']));
    $nipIngresado = $data['nip'];

    // Buscar usuario por EXPEDIENTE
    $user = UserModel::firstWhere('Expediente', $expediente);

    // Validar existencia
    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Expediente o NIP incorrectos'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // Verificar NIP
    if (!password_verify($nipIngresado, $user->NIP)) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Expediente o NIP incorrectos'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // Si está inactivo
    if ((int)$user->Activo === 0) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'El usuario está inactivo. Contacte con el administrador.'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // Éxito
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Inicio de sesión exitoso',
        'usuario' => [
            'ID'              => $user->ID,
            'Expediente'      => $user->Expediente,
            'Nombre'          => $user->Nombre,
            'ApellidoPaterno' => $user->ApellidoPaterno,
            'ApellidoMaterno' => $user->ApellidoMaterno,
            'Correo'          => $user->Correo,
            'Telefono'        => $user->Telefono,
            'Tipo'            => $user->Tipo
        ]
    ], JSON_UNESCAPED_UNICODE);
});
