clean:
	ls -al
	docker rm "$(CONTAINER_NAME)" || true

stop:
	docker stop "$(CONTAINER_NAME)" || true

build:
	docker build \
		--build-arg HTTP_PROXY="$(HTTP_PROXY)" \
		--build-arg HTTPS_PROXY="$(HTTPS_PROXY)" \
		--build-arg NO_PROXY="$(NO_PROXY)" \
		-t $(IMAGE_NAME):$(IMAGE_TAG) .

run:
	docker run -dit --rm --network=host --gpus all --shm-size=10gb \
		--name "$(CONTAINER_NAME)" \
		-e HF_TOKEN="$(HF_TOKEN)" \
		-e GEMINI_API_KEY="$(GEMINI_API_KEY)" \
		$(IMAGE_NAME):$(IMAGE_TAG) bash

exec:
	docker exec "$(CONTAINER_NAME)" \
		python /app/LRG/script/response_e2e.py --config_path=$(CONFIG_PATH)