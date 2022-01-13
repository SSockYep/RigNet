require("config")
package.projectPath='../Samples/classification/'
package.path=package.path..";../Samples/classification/lua/?.lua" --;"..package.path
require("common")
require("module")

skinscale=100

function loadRigInfo(filepath, skinscale)
    local output={}
    output.joints={}
    output.skin={}
    output.hier={}
    for line in io.lines(filepath) do
        local split = {}
        for k in string.gmatch(line, "[^%s]+") do
           split[#split+1]=k
        end
        if split[1] == "joints" then
            joint_pos=vector3(tonumber(split[3]),tonumber(split[4]),tonumber(split[5]))
            output.joints[split[2]]=joint_pos
            output.skin[split[2]]={}
        elseif split[1] == "root" then
            output.root=split[2]
        elseif split[1] == "skin" then
            local vertex = tonumber(split[2])
            local i=3
            while i <= #split do
                output.skin[split[i]][vertex]=tonumber(split[i+1])
                i = i+2
            end
        elseif split[1] == "hier" then
            -- TODO: Add some variables to show skeleton
        end
    end
    return output
end

function showBones()
    dbg.eraseAllDrawn()
    for k, v in pairs(rig_info[0].joints) do
        dbg.draw("Sphere", v*100, tostring(k), "green", 2)
    end
end

function ctor()
    local bgnode=RE.ogreSceneManager():getSceneNode("BackgroundNode")
    bgnode:setVisible(false)

    mesh=Geometry()
    file_dir = "/home/calab/RigNet/quick_start/"
    --model_id = "2586"
    model_id = "rigging_test"
    mesh:loadOBJ(file_dir..model_id.."_normalized.obj")
    rig_info = {}
    for i = 0, 9 do
        rig_info[i] = loadRigInfo(file_dir..model_id.."_ori_rig"..tostring(i)..".txt")
    end
    this:create("Button", "showBones", "showBones")
    this:newLine()
    this:setWidgetHeight(150)
    this:create("Multi_Browser", "body parts", "body parts")
    do
        local mBrowser=this:widget(0)
        mBrowser:browserClear()
        for k, v in pairs(rig_info[0].joints) do
            mBrowser:browserAdd(k)
        end
        joint = mBrowser:browserText(mBrowser:browserValue())
    end
    this:create("Multi_Browser", "variance", "variance")
    do
        local mBrowser=this:widget(0)
        mBrowser:browserClear()
        for i = 0,9 do
            mBrowser:browserAdd(tostring(i))
        end
    end
    var_idx = 0

    local meshToEntity=MeshToEntity(mesh, 'meshName')
    local entity=meshToEntity:createEntity('entityName')
    local materialName='lightgrey_transparent'
    entity:setMaterialName(materialName)
    local node=RE.createChildSceneNode(RE.ogreRootSceneNode(), "mesh_node")
    node:setScale(100, 100, 100)
    node:attachObject(entity)
end

function dtor()
end

function draw_weights()
    dbg.eraseAllDrawn()
    showBones()
    dbg.draw("Sphere", rig_info[var_idx].joints[joint]*100, tostring(joint), "red", 2)
    for k, v in pairs(rig_info[var_idx].skin[joint]) do
        dbg.draw("Sphere", mesh:getVertex(k)*100, tostring(k), "blue", v)
    end
end

function onCallback(w, userData)
    if w:id()=="body parts" then
        joint = w:browserText(w:browserValue())
        draw_weights()
    elseif w:id()=="variance" then
        var_idx = w:browserValue() - 1
        draw_weights()
    elseif w:id()=="showBones" then
        showBones()
    end
end

function frameMove(fElapsedTime)
end