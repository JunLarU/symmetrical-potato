import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class Main extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception {
        // Cargar FXML desde la carpeta 'views'
        FXMLLoader loader = new FXMLLoader(getClass().getResource("/app/views/hellofx.fxml"));
        Parent root = loader.load();

        Scene scene = new Scene(root, 400, 400);

        // Agregar CSS desde la carpeta 'assets/css'
        scene.getStylesheets().add(getClass().getResource("/app/assets/css/app.css").toExternalForm());
        primaryStage.getIcons().add(new javafx.scene.image.Image(getClass().getResourceAsStream("/app/assets/img/CAFI_LOGO.png")));
        primaryStage.setTitle("Login");
        primaryStage.setResizable(false);
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
