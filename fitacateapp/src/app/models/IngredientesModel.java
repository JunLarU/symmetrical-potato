package app.models;

import core.http.HttpClientSingleton;
import org.json.JSONObject;

/**
 * Modelo de comunicación con el backend para la gestión de ingredientes.
 * Compatible con las rutas:
 * - POST /ingredients/all
 * - POST /ingredients/search
 */
public class IngredientesModel {

    /**
     * Obtiene la lista completa de ingredientes.
     * 
     * @param expedienteAdmin Expediente del administrador autenticado.
     * @return JSONObject con campos: success, total, ingredientes[]
     * @throws Exception en caso de error de red o formato.
     */
    public JSONObject obtenerTodos(String expedienteAdmin) throws Exception {
        JSONObject body = new JSONObject();
        body.put("expediente_admin", expedienteAdmin);

        System.out.println("📡 Enviando solicitud a /ingredients/all:");
        System.out.println(body.toString(4));

        String response = HttpClientSingleton.getInstance()
                .post("ingredients/all", body.toString());

        if (response == null || response.isBlank()) {
            throw new Exception("Respuesta vacía del servidor.");
        }

        JSONObject jsonResponse;
        try {
            jsonResponse = new JSONObject(response);
        } catch (Exception e) {
            throw new Exception("El servidor no devolvió JSON válido:\n" + response);
        }

        return jsonResponse;
    }

    /**
     * Realiza una búsqueda de ingredientes por texto parcial.
     * 
     * @param expedienteAdmin Expediente del administrador autenticado.
     * @param query           Texto de búsqueda (por nombre, categoría, etc.).
     * @return JSONObject con campos: success, total, ingredientes[]
     * @throws Exception en caso de error de red o formato.
     */
    public JSONObject buscar(String expedienteAdmin, String query) throws Exception {
        JSONObject body = new JSONObject();
        body.put("expediente_admin", expedienteAdmin);
        body.put("query", query);

        System.out.println("📡 Enviando solicitud a /ingredients/search:");
        System.out.println(body.toString(4));

        String response = HttpClientSingleton.getInstance()
                .post("ingredients/search", body.toString());

        if (response == null || response.isBlank()) {
            throw new Exception("Respuesta vacía del servidor.");
        }

        JSONObject jsonResponse;
        try {
            jsonResponse = new JSONObject(response);
        } catch (Exception e) {
            throw new Exception("El servidor no devolvió JSON válido:\n" + response);
        }

        return jsonResponse;
    }

    /**
 * Envía al servidor un nuevo ingrediente.
 */
    public JSONObject agregarIngrediente(String expedienteAdmin,
                                        String nombre,
                                        String descripcion,
                                        String categoria,
                                        String calorias,
                                        boolean alergeno) throws Exception {
        JSONObject body = new JSONObject();
        body.put("expediente_admin", expedienteAdmin);
        body.put("nombre", nombre);
        body.put("descripcion", descripcion);
        body.put("categoria", categoria);
        body.put("calorias", calorias);
        body.put("alergeno", alergeno ? 1 : 0);

        System.out.println("📡 Enviando solicitud a /ingredients/add:");
        System.out.println(body.toString(4));

        String response = core.http.HttpClientSingleton.getInstance()
                .post("ingredients/add", body.toString());

        if (response == null || response.isBlank()) {
            throw new Exception("Respuesta vacía del servidor.");
        }

        try {
            return new JSONObject(response);
        } catch (Exception e) {
            throw new Exception("El servidor no devolvió JSON válido:\n" + response);
        }
    }


}
