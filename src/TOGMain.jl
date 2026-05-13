module TOGMain

const T = Float32
export T

using Revise, ArgParse, Pkg
using TOG: 𝕋, t
using TOGZMQServer, TOGgod, TOGREPL, TOGCommunicationServer

const Ω = 𝕋()

const ROUTERLOCATION = "ipc://$(pwd())/router.ipc" # change to tcp if on separate machines
const PUBLOCATION = "ipc://$(pwd())/pub.ipc" # change to tcp if on separate machines
const TOGLOCATION = "ipc://$(pwd())/tog.ipc" # change to tcp if on separate machines

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--update"
        action = :store_true
        "names"
        nargs = '*'
        arg_type = String
        # default = ["TOGHuman", "TOGDona", "TOGJanet"]
        default = ["TOGHuman"]
    end
    return parse_args(s)
end
function (@main)(ARGS)
    # DEPOT_PATH[1]=joinpath(pwd(),".loopos")
    config = parse_commandline()
    config["update"] && return Pkg.update()
    TOGZMQServer.awaken(TOGLOCATION, Ω)
    TOGCommunicationServer.awaken(router=ROUTERLOCATION, pub=PUBLOCATION)
    [TOGgod.awaken(group="∀", name=name, router=ROUTERLOCATION, pub=PUBLOCATION, tog=TOGLOCATION) for name = config["names"]]
    TOGREPL.awaken(false)
    0
end

end
