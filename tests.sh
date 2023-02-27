#!/bin/bash
# url="https://erl-tf.global.ssl.fastly.net/status/501"
# url="https://erl-tf.global.ssl.fastly.net/?x-obj-status=200"
# url="https://erl-tf.global.ssl.fastly.net/foo/v1/menu?x-obj-status=200"

#### origin response block - There should be a block at the origin based on the "206" response code
# url="https://erl-tf.global.ssl.fastly.net/path_origin_response_block?x-obj-status=206"


while true
do
    # sleep 1
    # curl -sD - -o /dev/null $url -w 'http_code: %{http_code}'

    curl -o /dev/null $url -w 'http_code: %{http_code}\t'
done

##### Alternatively `siege $url`
# siege https://erl-tf.global.ssl.fastly.net/foo/v1/menu?x-obj-status=200
# siege https://erl-tf.global.ssl.fastly.net/foo/v1/menu?x-obj-status=206
