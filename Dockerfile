# ============================================================
# Stage 1: Build — Compilar el proyecto con Maven
# ============================================================
FROM eclipse-temurin:25-jdk AS build

# Instalar SWI-Prolog (necesario para compilar contra jpl.jar)
RUN apt-get update && \
    apt-get install -y --no-install-recommends swi-prolog-core swi-prolog-java && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar Maven wrapper y pom.xml primero para cache de dependencias
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
COPY lib/ lib/

# Descargar dependencias (capa cacheada)
RUN chmod +x mvnw && ./mvnw dependency:resolve -q

# Copiar fuentes y compilar
COPY src/ src/
COPY sistema_experto.pl .

RUN ./mvnw package -DskipTests -q

# ============================================================
# Stage 2: Runtime — Imagen liviana para ejecución
# ============================================================
FROM eclipse-temurin:25-jdk-noble AS runtime

# Instalar SWI-Prolog con bindings JPL
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        swi-prolog-core \
        swi-prolog-java && \
    rm -rf /var/lib/apt/lists/*

# Localizar libjpl.so y configurar LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH="/usr/lib/swi-prolog/lib/x86_64-linux:/usr/lib/x86_64-linux-gnu"

WORKDIR /app

# Copiar el JAR compilado
COPY --from=build /app/target/*.jar app.jar

# Copiar la base de conocimiento Prolog
COPY sistema_experto.pl .

# Copiar jpl.jar (necesario en runtime como system dependency)
COPY lib/jpl.jar lib/jpl.jar

EXPOSE 8080

# Healthcheck para verificar que la app responde
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/swagger-ui.html || exit 1

ENTRYPOINT ["java", \
    "--enable-native-access=ALL-UNNAMED", \
    "-Djava.library.path=/usr/lib/swi-prolog/lib/x86_64-linux", \
    "-cp", "lib/jpl.jar:app.jar", \
    "org.springframework.boot.loader.launch.JarLauncher"]
