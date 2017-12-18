static func shuffle_list(list):
    var shuffled_list = []
    var index_list = range(list.size())
    for i in range(list.size()):
        randomize()
        var x = randi()%index_list.size()
        shuffled_list.append(list[x])
        index_list.remove(x)
        list.remove(x)
    return shuffled_list

static func get_random_with_meta(list, params):
    var shuffled_list = shuffle_list(list)
    for i in shuffled_list:
        var matched = true
        for k in params.keys():
            if i.get_meta(k) != params[k]:
                matched = false
                break
        if matched:
            return i
    return null