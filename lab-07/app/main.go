package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	dbHost := os.Getenv("DB_HOST")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	dbPort := os.Getenv("DB_PORT")

	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		dbHost, dbPort, dbUser, dbPassword, dbName)

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		db, err := sql.Open("postgres", connStr)
		if err != nil {
			http.Error(w, "Error de configuración de BD", 500)
			return
		}
		defer db.Close()

		err = db.Ping()
		if err != nil {
			http.Error(w, fmt.Sprintf("Error conectando a la BD: %v", err), 500)
			return
		}

		fmt.Fprintf(w, "¡Conexión exitosa a PostgreSQL desde el contenedor de Go!")
	})

	log.Println("Servidor escuchando en el puerto 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}