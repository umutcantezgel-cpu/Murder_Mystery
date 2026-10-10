# Mordakte-Server.
# Build-Kontext ist das REPO-ROOT, weil der Server packages/mordakte_core braucht:
#   docker build -f server/Dockerfile -t mordakte-server .
#   docker run --rm -p 8080:8080 mordakte-server

# --- Stage 1: kompilieren ----------------------------------------------------
FROM dart:stable AS build
WORKDIR /src

# Erst nur die pubspecs → Abhängigkeiten werden gecacht.
COPY packages/mordakte_core/pubspec.yaml packages/mordakte_core/
COPY server/pubspec.yaml server/pubspec.lock server/
RUN cd server && dart pub get

COPY packages/mordakte_core packages/mordakte_core
COPY server server
COPY content content

RUN mkdir -p /out/content/scenarios /out/content/party/schlosskeller \
 && cd server \
 && dart pub get --offline \
 && dart compile exe bin/server.dart -o /out/server \
 && if [ -d /src/content/scenarios ]; then cp -r /src/content/scenarios/. /out/content/scenarios/; fi \
 && cp -r /src/content/party/schlosskeller/. /out/content/party/schlosskeller/

# --- Stage 2: minimales Laufzeit-Image ---------------------------------------
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /out/server /app/bin/server
COPY --from=build /out/content/scenarios /app/content/scenarios
COPY --from=build /out/content/party/schlosskeller /app/content/party/schlosskeller

ENV SCENARIO_DIR=/app/content/scenarios
ENV PARTY_DIR=/app/content/party/schlosskeller
EXPOSE 8080
USER 65532:65532
CMD ["/app/bin/server"]
