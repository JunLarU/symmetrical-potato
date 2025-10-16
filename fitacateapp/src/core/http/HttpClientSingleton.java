package core.http;

import core.config.AppConfig;
import javax.net.ssl.*;
import java.net.http.*;
import java.net.URI;
import java.security.cert.X509Certificate;
import java.time.Duration;

public class HttpClientSingleton {

    private static HttpClientSingleton instance;
    private final HttpClient client;

    private HttpClientSingleton() {
        try {
            HttpClient.Builder builder = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(AppConfig.CONNECTION_TIMEOUT))
                    .followRedirects(HttpClient.Redirect.NORMAL);

            // Si estamos en desarrollo y usamos certificados autofirmados
            if (AppConfig.ALLOW_SELF_SIGNED_SSL) {
                SSLContext sslContext = SSLContext.getInstance("TLS");
                sslContext.init(null, new TrustManager[]{ new X509TrustManager() {
                    public void checkClientTrusted(X509Certificate[] xcs, String string) {}
                    public void checkServerTrusted(X509Certificate[] xcs, String string) {}
                    public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[0]; }
                }}, new java.security.SecureRandom());
                builder.sslContext(sslContext);
            }

            this.client = builder.build();
        } catch (Exception e) {
            throw new RuntimeException("Error inicializando cliente HTTP", e);
        }
    }

    public static HttpClientSingleton getInstance() {
        if (instance == null) {
            synchronized (HttpClientSingleton.class) {
                if (instance == null)
                    instance = new HttpClientSingleton();
            }
        }
        return instance;
    }

    // Método genérico GET
    public String get(String endpoint) throws Exception {
        String url = AppConfig.SERVER_URL + endpoint;
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Accept", "application/json")
                .GET()
                .build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }

    // Método genérico POST
    public String post(String endpoint, String jsonBody) throws Exception {
        String url = AppConfig.SERVER_URL + endpoint;
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return response.body();
    }
}
