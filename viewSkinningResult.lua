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
    for k, v in pairs(rig_info.joints) do
        dbg.draw("Sphere", v*100, tostring(k), "green", 2)
    end
end

function ctor()
    local bgnode=RE.ogreSceneManager():getSceneNode("BackgroundNode")
    bgnode:setVisible(false)

    mesh=Geometry()
    file_dir = "/home/calab/RigNet/quick_start/"
    model_id = "2586"
    mesh:loadOBJ(file_dir..model_id.."_normalized.obj")
    rig_info = loadRigInfo(file_dir..model_id.."_ori_rig1.txt")

    this:create("Button", "showBones", "showBones")
    this:newLine()
    this:setWidgetHeight(150)
    this:create("Multi_Browser", "body parts", "body parts")
    do
        local mBrowser=this:widget(0)
        mBrowser:browserClear()
        for k, v in pairs(rig_info.joints) do
            mBrowser:browserAdd(k)
        end
    end

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

function onCallback(w, userData)
    if w:id()=="body parts" then
        dbg.eraseAllDrawn()
        showBones()
        local joint = w:browserText(w:browserValue())
        dbg.draw("Sphere", rig_info.joints[joint]*100, tostring(joint), "red", 2)
        for k, v in pairs(rig_info.skin[joint]) do
            dbg.draw("Sphere", mesh:getVertex(k)*100, tostring(k), "blue", v)
        end
    elseif w:id()=="showBones" then
        showBones()
    end
end

function frameMove(fElapsedTime)
end