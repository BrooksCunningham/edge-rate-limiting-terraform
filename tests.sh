# url="https://erl-tf.global.ssl.fastly.net/status/501"
url="https://erl-tf.global.ssl.fastly.net/?x-obj-status=404"
while true
do
    sleep 1
    # curl -sD - -o /dev/null $url -w 'http_code: %{http_code}'

    curl -o /dev/null $url -w 'http_code: %{http_code}\t'
done
