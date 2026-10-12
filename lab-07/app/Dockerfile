# ==========================================
### --- Etapa 1 (builder) --- ###
# ==========================================

# Usa la imagen base oficial golang:1.22-alpine (asígna un alias con AS builder).
FROM golang:1.22-alpine AS builder

# Define un WORKDIR /app.
WORKDIR /app

# Copia los archivos del código (go.mod, go.sum o main.go).
COPY main.go ./

# Inicializamos los módulos de Go, descargamos el driver de PostgreSQL y compilamos
# - CGO_ENABLED=0 y GOOS=linux aseguran que el binario sea 100% estático para Linux
RUN go mod init app && \
    go get github.com/lib/pq && \
    CGO_ENABLED=0 GOOS=linux go build -o main .

# ==========================================
### --- Etapa 2 (final) --- ###
# ==========================================

# Usa una imagen ultra ligera de ejecución como alpine:3.19 o incluso scratch.
FROM alpine:3.19

# Define WORKDIR /app.
WORKDIR /app

# MAGIA DEL MULTI-STAGE: Copiamos ÚNICAMENTE el archivo binario 'main' de la etapa anterior
# Descartamos por completo los 800MB del compilador de Go
COPY --from=builder /app/main .

# Expón el puerto 8080 (EXPOSE 8080).
EXPOSE 8080

# Define el punto de entrada para ejecutar el binario: CMD ["./main"].
CMD ["./main"]