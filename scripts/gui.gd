extends CanvasLayer

func set_coins(coins):
    get_nome("coins").set_text("%06d" % coins)

func set_health(health):
    var progress = get_node("health")
    if health >= 50:
        progress.get("custom_styles/fg").set_bg_color(Color("009e02"))
    elif health >= 20:
        progress.get("custom_styles/fg").set_bg_color(Color("cae938"))
    else:
        progress.get("custom_styles/fg").set_bg_color(Color("b6000c"))
    progress.set_value(health)