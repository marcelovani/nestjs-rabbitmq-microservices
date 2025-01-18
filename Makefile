include .env
export $(shell sed 's/=.*//' .env)

VENDOR=${DOCKER_CONTAINER_VENDOR}
ECR_URL=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

ecr-login:
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

build-docker-images:
	docker buildx build -f apps/auth/Dockerfile 	--force-rm -t ${VENDOR}/ordering-app_auth .
	docker buildx build -f apps/billing/Dockerfile 	--force-rm -t ${VENDOR}/ordering-app_billing .
	docker buildx build -f apps/orders/Dockerfile 	--force-rm -t ${VENDOR}/ordering-app_orders .

deploy-docker-images:
	docker tag ${VENDOR}/ordering-app_auth:latest 		${ECR_URL}/${VENDOR}/ordering-app_auth:latest
	docker tag ${VENDOR}/ordering-app_billing:latest 	${ECR_URL}/${VENDOR}/ordering-app_billing:latest
	docker tag ${VENDOR}/ordering-app_orders:latest 	${ECR_URL}/${VENDOR}/ordering-app_orders:latest

	docker push ${ECR_URL}/${VENDOR}/ordering-app_auth:latest
	docker push ${ECR_URL}/${VENDOR}/ordering-app_billing:latest
	docker push ${ECR_URL}/${VENDOR}/ordering-app_orders:latest
