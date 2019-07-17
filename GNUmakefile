.ONESHELL: \
	#



# Pattern rules

lambda/layers/%: FORCE
	cd $@
	BUNDLE_CACHE_PATH=../../../.gems bundle package

lambda/%.tar: FORCE
	s3am fetch --bucket BUCKET --object-key $@FIXME $@



# Targets

.PHONY: \
	all \
	deploy \
	gem-index \
	package \
	s3-index \
	FORCE \
	#


all: deploy


gem-index: lambda/layers/octokit

s3-index: deploy-bootstrap lambda/functions/webhook.tar lambda/functions/events/installation.tar

prepare: gem-index s3-index


package:
	tup


upload-lambda-functions-webhook: package
	s3am add --bucket $(shell cat .lambda_artifacts_bucket.txt) --object-key /functions/webhook.zip lambda/functions/webhook.tar lambda/functions/webhook.zip > lambda/functions/webhook.txt


deploy-bootstrap:
	sceptre bootstrap

deploy-webhook: upload-lambda-functions-webhook
	sceptre webhook

deploy:
	sceptre
