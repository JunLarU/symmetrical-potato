<?php

use Whis\Routing\Route;
use App\Models\UserModel;
use App\Models\IngredientModel;

Route::post('/api/ingredients/all', function () {
    header('Content-Type: application/json; charset=utf-8');
    $data = json_decode(file_get_contents('php://input'), true);

    if (json_last_error() !== JSON_ERROR_NONE || empty($data['expediente_admin'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Falta expediente_admin']);
        return;
    }

    $admin = UserModel::firstWhere('Expediente', strtoupper(trim($data['expediente_admin'])));
    if (!$admin || $admin->Tipo !== 'Administrador' || (int)$admin->Activo === 0) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'Administrador no autorizado']);
        return;
    }

    try {
        $ingredientes = IngredientModel::allWithCategory();

        http_response_code(200);
        echo json_encode([
            'success' => true,
            'total' => count($ingredientes),
            'ingredientes' => $ingredientes
        ], JSON_UNESCAPED_UNICODE);
    } catch (\Throwable $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error al obtener los ingredientes',
            'error' => $e->getMessage()
        ], JSON_UNESCAPED_UNICODE);
    }
});


Route::post('/api/ingredients/search', function () {
    header('Content-Type: application/json; charset=utf-8');
    $data = json_decode(file_get_contents('php://input'), true);

    if (json_last_error() !== JSON_ERROR_NONE || empty($data['expediente_admin']) || empty($data['query'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Datos incompletos']);
        return;
    }

    $admin = UserModel::firstWhere('Expediente', strtoupper(trim($data['expediente_admin'])));
    if (!$admin || $admin->Tipo !== 'Administrador' || (int)$admin->Activo === 0) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'Administrador no autorizado']);
        return;
    }

    try {
        $result = IngredientModel::searchSafe($data['query']);
        http_response_code(200);
        echo json_encode([
            'success' => true,
            'total' => count($result),
            'ingredientes' => $result
        ], JSON_UNESCAPED_UNICODE);
    } catch (\Throwable $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error al realizar la búsqueda',
            'error' => $e->getMessage()
        ], JSON_UNESCAPED_UNICODE);
    }
});

Route::post('/api/ingredients/add', function () {
    header('Content-Type: application/json; charset=utf-8');
    $data = json_decode(file_get_contents('php://input'), true);

    // === Validación básica del JSON ===
    if (json_last_error() !== JSON_ERROR_NONE || empty($data)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'JSON inválido o cuerpo vacío'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // === Verificar campos requeridos ===
    $required = ['expediente_admin', 'nombre', 'categoria'];
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

    // === Verificar administrador ===
    $admin = UserModel::firstWhere('Expediente', strtoupper(trim($data['expediente_admin'])));
    if (!$admin || $admin->Tipo !== 'Administrador' || (int)$admin->Activo === 0) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'Administrador no autorizado'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // === Buscar categoría ===
    $driver = IngredientModel::getDatabaseDriver();
    $catQuery = "SELECT ID FROM CategoriasIngredientes WHERE Nombre = :nombre LIMIT 1;";
    $catResult = $driver->statement($catQuery, [':nombre' => trim($data['categoria'])]);

    if (!$catResult || count($catResult) === 0) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'La categoría especificada no existe'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    $idCategoria = (int)$catResult[0]['ID'];

    // === Validar valores opcionales ===
    $descripcion = isset($data['descripcion']) ? trim($data['descripcion']) : null;
    $calorias = isset($data['calorias']) ? floatval($data['calorias']) : null;
    $alergeno = isset($data['alergeno']) ? intval($data['alergeno']) : 0;

    // === Evitar duplicados por nombre ===
    $existente = IngredientModel::firstWhere('Nombre', trim($data['nombre']));
    if ($existente) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'Ya existe un ingrediente con ese nombre'
        ], JSON_UNESCAPED_UNICODE);
        return;
    }

    // === Inserción ===
    try {
        $driver->statement(
            "INSERT INTO Ingredientes (Nombre, IDCategoria, Descripcion, Calorias, Alergeno) 
             VALUES (:nombre, :idcat, :desc, :cal, :alerg)",
            [
                ':nombre' => ucwords(trim($data['nombre'])),
                ':idcat'  => $idCategoria,
                ':desc'   => $descripcion,
                ':cal'    => $calorias,
                ':alerg'  => $alergeno
            ]
        );

        // Obtener el último ID insertado
        $idNuevo = $driver->lastInsertedId();

        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'Ingrediente agregado correctamente',
            'id' => intval($idNuevo)
        ], JSON_UNESCAPED_UNICODE);
    } catch (\Throwable $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Error interno al registrar el ingrediente',
            'error' => $e->getMessage()
        ], JSON_UNESCAPED_UNICODE);
    }
});

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
