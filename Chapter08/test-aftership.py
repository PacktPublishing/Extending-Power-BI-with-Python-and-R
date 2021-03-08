
import aftership
import json

aftership.api_key = 'f0835c46-9629-466d-aa4b-54df889b7ce7'

# To solve the "SSL" error I first installed OpenSSL from here:
# https://slproweb.com/products/Win32OpenSSL.html
# 
# Then I run conda init as suggested here: https://stackoverflow.com/a/63291118/416988
# Try first only the "conda init" fix. If it doesn't work, try to install OpenSSL

couriers = aftership.courier.list_couriers()
# print(couriers)

trck = {
        "tracking_number": "1Z0X00F37959785467"
}

courier = aftership.courier.detect_courier(tracking=trck)
slug = courier["couriers"][0]["slug"]

trck2 = {
        "slug": slug,
        "tracking_number": "1Z0X00F37959785467"
}
trck_res = aftership.tracking.create_tracking(trck2)

trck_id = trck_res["tracking"]["id"]

tracking = aftership.tracking.get_tracking(tracking_id=trck_id)

aftership.tracking.get_last_checkpoint(tracking_id=trck_id)


# How to get a list of trackings

# import aftership
# aftership.api_key = "xxx"
# data = aftership.tracking.list_trackings({
# "limit": "200",
# "page": "1",
# "created_at_min": "2021-01-10T13:00:06",
# "created_at_max": "2021-12-14T23:00:06",
# "tag": "InfoReceived,InTransit,OutForDelivery,AttemptFail,Delivered,AvailableForPickup,Exception"
# })
# print(data)
