# eterna-solr

Minimal container-image för Apache Solr 9, byggd med [melange](https://github.com/chainguard-dev/melange) och [apko](https://github.com/chainguard-dev/apko) på [Wolfi](https://wolfi.dev).

Image: `ghcr.io/eterna-earkiv/solr:9.10.1` (linux/amd64, linux/arm64)

Solr 9 finns inte längre i Wolfi, så `solr-9.yaml` bygger Solr från källkod (port av Wolfis recept för 9.10.1-r4 inklusive deras beroendeuppdateringar). `melange.yaml` bygger startskriptet.

Säkerhetsuppdateringar av beroenden görs med `sed`-raderna i `solr-9.yaml` – höj då `epoch`.

Imagen körs som icke-root (uid 8983). Data ligger under `/var/solr` – volymer som monteras där måste ägas av uid 8983.

## Bygga lokalt

Kräver `melange`, `apko` och `docker`:

```sh
make            # bygger paket och image för x86_64 och laddar in i docker
make ARCH=aarch64
```

Utan installerade verktyg går det att köra dem via container:

```sh
make MELANGE="docker run --rm --privileged -v $PWD:/work -w /work cgr.dev/chainguard/melange:latest" \
     APKO="docker run --rm -v $PWD:/work -w /work cgr.dev/chainguard/apko:latest"
```

## Release

1. Uppdatera `VERSION` i `Makefile` (och versioner i `apko.yaml`/`melange`-filer).
2. Pusha en tagg `v<VERSION>`, t.ex. `git tag v9.10.1 && git push origin v9.10.1`.

GitHub Actions bygger paket för x86_64 och aarch64 på egna runners och publicerar en multi-arch-image till GHCR. Bygget kan också startas manuellt (*Run workflow*).

Paketen signeras med nyckeln i secret `MELANGE_RSA` (skapas med `melange keygen`).
