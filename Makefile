IMAGE    := solr
VERSION  := 9.11.0
ARCH     := x86_64
PACKAGES := ./packages
TAG      := $(VERSION)
REGISTRY := ghcr.io/eterna-earkiv
MELANGE  ?= melange
APKO     ?= apko

.PHONY: all keygen package image publish version clean

all: keygen package image

keygen:
	@test -f melange.rsa || $(MELANGE) keygen melange.rsa

package: keygen
	$(MELANGE) build solr-9.yaml \
	  --arch $(ARCH) \
	  --signing-key melange.rsa \
	  --out-dir $(PACKAGES)
	$(MELANGE) build melange.yaml \
	  --arch $(ARCH) \
	  --signing-key melange.rsa \
	  --out-dir $(PACKAGES)

image: package
	$(APKO) build apko.yaml --arch $(ARCH) \
	  $(IMAGE):$(TAG) \
	  $(IMAGE).tar
	docker load < $(IMAGE).tar
	docker tag $(IMAGE):$(TAG)-amd64 $(IMAGE):$(TAG)

# Bygger och pushar multi-arch-image (kräver paket för alla archs i apko.yaml)
publish:
	$(APKO) publish apko.yaml \
	  $(REGISTRY)/$(IMAGE):$(TAG)

version:
	@echo $(VERSION)

clean:
	rm -rf $(PACKAGES) $(IMAGE).tar melange.rsa melange.rsa.pub
