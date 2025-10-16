<?php

namespace App\Models;

use Whis\Database\Model;

class UserModel extends Model
{
    protected ?string $table = 'Usuarios';
    protected string $primaryKey = 'ID';

    protected array $fillable = [
        'Expediente',
        'Nombre',
        'ApellidoPaterno',
        'ApellidoMaterno',
        'NIP',
        'Correo',
        'Telefono',
        'Tipo',
        'Activo'
    ];

    protected array $hidden = ['NIP'];

    // 👇 Desactivar timestamps automáticos
    protected bool $insertTimestamps = false;
}
