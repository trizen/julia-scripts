#!/usr/bin/julia

# Author: Daniel "Trizen" Șuteu
# License: GPLv3
# Date: 15th October 2013
# http://trizenx.blogspot.com
# http://trizenx.blogspot.ro/2013/11/smart-word-wrap.html
# Email: <echo dHJpemVueEBnbWFpbC5jb20K | base64 -d>

# Smart word wrap algorithm
# See: http://en.wikipedia.org/wiki/Word_wrap#Minimum_raggedness

# This is the ugliest method! It, recursively,
# prepares the words for the combine() function.
function prepare_words(array, width, callback, depth=0)

    root, len, i = [], 0, 0
    limit = length(array)

    while ((i+=1) <= limit)
        len += (word_len = length(array[i]))

        if len > width
             if word_len > width
                    len -= word_len
                    value = array[i]
                    a = matchall(Regex(".{1,$width}"), value)
                    splice!(array, i, map(x -> convert(String, x), a))
                    limit = length(array)
                    i -= 1
                    continue
                end
            break
        end

        push!(root, Any[
            join(array[1:i], ' '),
            prepare_words(array[i+1 : limit], width, callback, depth+1)
        ])

        if depth == 0
            callback(root[1])
            root = []
        end

        ((len += 1) >= width) && break
    end

    root
end

# This function combines the
# the parents with the childrens.
function combine(root, path, block)
    key = shift!(path)
    for value in path
        push!(root, key)
        if isempty(value)
            block(root)
        else
            for item in value
                combine(root, item, block)
            end
        end
        pop!(root)
    end
end

# This is the main function of the algorithm
# which calls all the other functions and
# returns the best possible wrapped string.
function smart_wrap(text, width)

    words = isa(text, AbstractString) ? split(text) : text

    best = Dict{String, Any}(
        "score" => Inf,
        "value" => [],
    )

    prepare_words(words, width, function (path)
        combine([], path, function (combination)
            score = 0
            for line in combination[1:length(combination)-1]
                score += (width - length(line))^2
            end

            if score < best["score"]
                best["score"] = score
                best["value"] = copy(combination)
            end
        end)
    end)

    join(best["value"], "\n")
end

#
## Usage examples
#

text = "aaa bb cc ddddd"
println(smart_wrap(text, 6))

println("-" ^ 80)

text = "As shown in the above phases (or steps), the algorithm does many useless transformations"
println(smart_wrap(text, 20))

println("-" ^ 80)

text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
println(smart_wrap(text, 20))

println("-" ^ 80)

text = "Lorem ipsum dolor ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ amet, consectetur adipiscing elit."
println(smart_wrap(text, 20))

println("-" ^ 80)

text = "Will Perl6 also be pre-installed on future Mac/Linux operating systems? ... I can\'t predict the success of the project...";
println(smart_wrap(text, 20))
