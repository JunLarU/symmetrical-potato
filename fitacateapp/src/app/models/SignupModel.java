package app.models;

import core.http.HttpClientSingleton;
import org.json.JSONObject;

public class SignupModel {

    public JSONObject registrarUsuario(
            String expediente,
            String nombre,
            String apellidoPaterno,
            String apellidoMaterno,
            String correo,
            String telefono,
            String nip,
            String tipo,
            String expedienteAdmin // 👈 nuevo parámetro
    ) throws Exception {

        JSONObject data = new JSONObject();
        data.put("expediente", expediente);
        data.put("nombre", nombre);
        data.put("apellido_paterno", apellidoPaterno);
        data.put("apellido_materno", apellidoMaterno);
        data.put("correo", correo);
        data.put("telefono", telefono);
        data.put("nip", nip);
        data.put("tipo", tipo);

        // Solo incluir expediente del admin si existe
        if (expedienteAdmin != null && !expedienteAdmin.isBlank()) {
            data.put("expediente_admin", expedienteAdmin);
        }

        System.out.println("📡 Enviando JSON al servidor (signup):");
        System.out.println(data.toString(4));

        String response = HttpClientSingleton.getInstance()
                .post("users/signup", data.toString());

        if (response == null || response.isBlank()) {
            throw new Exception("Respuesta vacía del servidor.");
        }

        return new JSONObject(response);
    }
}
