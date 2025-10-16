<?php

namespace App\Models;

use Whis\Database\Model;

class IngredientModel extends Model
{
    protected ?string $table = 'Ingredientes';
    protected string $primaryKey = 'ID';

    protected array $fillable = [
        'ID',
        'Nombre',
        'IDCategoria',
        'Descripcion',
        'Calorias',
        'Alergeno'
    ];

    protected bool $insertTimestamps = false;

    /**
     * Buscar ingredientes por nombre, descripción o categoría
     * (LIKE seguro y parametrizado)
     */
    public static function searchSafe(string $query, int $limit = 50): array
    {
        $instance = new static();
        $driver = self::getDatabaseDriver();

        // Limpiar texto de búsqueda
        $query = trim($query);
        $query = filter_var($query, FILTER_UNSAFE_RAW);

        // Consulta SQL con JOIN hacia Categorías
        $sql = "
            SELECT 
                i.ID,
                i.Nombre,
                i.IDCategoria,
                c.Nombre AS Categoria,
                i.Descripcion,
                i.Calorias,
                i.Alergeno
            FROM Ingredientes i
            LEFT JOIN CategoriasIngredientes c ON i.IDCategoria = c.ID
            WHERE 
                i.Nombre LIKE :query
                OR i.Descripcion LIKE :query
                OR c.Nombre LIKE :query
            ORDER BY i.Nombre ASC
            LIMIT {$limit};
        ";

        $params = [':query' => '%' . $query . '%'];
        $result = $driver->statement($sql, $params);

        if (!$result || count($result) === 0) {
            return [];
        }

        $models = [];
        foreach ($result as $row) {
            $models[] = (new static())->setAttributes($row)->toArray();
        }

        return $models;
    }

    /**
     * Obtener todos los ingredientes con categoría incluida
     */
    public static function allWithCategory(): array
    {
        $instance = new static();
        $driver = self::getDatabaseDriver();

        $sql = "
            SELECT 
                i.ID,
                i.Nombre,
                i.IDCategoria,
                c.Nombre AS Categoria,
                i.Descripcion,
                i.Calorias,
                i.Alergeno
            FROM Ingredientes i
            LEFT JOIN CategoriasIngredientes c ON i.IDCategoria = c.ID
            ORDER BY i.Nombre ASC;
        ";

        $result = $driver->statement($sql);

        if (!$result || count($result) === 0) {
            return [];
        }

        $models = [];
        foreach ($result as $row) {
            $models[] = (new static())->setAttributes($row)->toArray();
        }

        return $models;
    }
}
