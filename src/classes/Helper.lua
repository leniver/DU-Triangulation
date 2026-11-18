---@class Helper : Widget
---@field system System
---@field version string
---@field translator Translator
---@field backgroundColor string
---@field open boolean
Helper = Class(Widget)


---@param system System
---@param translator Translator
---@return Helper
function Helper:init(system, translator)
    self.system = system
    self.version = "1.0.0"
    self.translator = translator
    self.backgroundColor = ToRGB(baseColor)

    self.open = false
end


function Helper:render()
    if self.open then
        local key = self.system.getActionKeyName
        return {
            style = [[
            .help {
            background: rgba(]] .. self.backgroundColor .. [[, 0.8);
            font-size: 13px;
            left: 10px;
            line-height: 1.25em;
            min-height: 500px;
            padding: 40px;
            position: absolute;
            top: 360px;
            top: 30px;
            width: 630px;
            z-index: 10;
        }
            .help b{
            background: #ffffff;
            color: rgba(2,52,110, 1);
            display: block;
            font-size: 1.1em;
            font-weight: bold;
            margin-bottom: 5px;
            margin-top: 10px;
            padding: 5px;
            text-align: center;
        }
            .help label{
            display: inline-block;
            vertical-align: top;
            width: 50%;
        }
            .help span{
            display: inline-block;
            width: 50%;
        }
            .help .split{
            display: flex;
            justify-content: space-between;
        }
            .help .split > div{
            width: 49%;
        }
            .help .split > div label{
            width: 60%;
        }
            .help .split > div span{
            width: 40%;
        }
            .version{
            bottom: 5px;
            font-size: 10px;
            position: fixed;
            right: 100px;
        }

            ]],
            html = [[
            <div class="help">
            <b>]] .. self.translator:get("Triangulation") .. [[</b>
            <label>]] .. self.translator:get("Add reading") .. [[</label><span> ]] .. key("speedup") .. [[</span><br/>
            <label>]] .. self.translator:get("Show/hide (resets)") .. [[</label><span> ]] .. key("speeddown") .. [[</span><br/>
            <label>]] .. self.translator:get("Fast scroll") .. [[</label><span>]] .. key("lshift") .. [[ + ]] .. self.translator:get("mouse wheel") .. [[</span></br>
            <label>]] .. self.translator:get("Track distance to result") .. [[</label><span> ]] .. key("booster") .. [[</span><br/>
            <b>]] .. self.translator:get("Calibration") .. [[</b>
            <label>]] .. self.translator:get("Calibration mode") .. [[</label><span> ]] .. key("option8") .. [[</span><br/>
            <label>]] .. self.translator:get("Move overlay up/down") .. [[</label><span> ]] .. key("up") .. [[ / ]] .. key("down") .. [[</span><br/>
            <label>]] .. self.translator:get("Move overlay left/right") .. [[</label><span> ]] .. key("strafeleft") .. [[ / ]] .. key("straferight") .. [[</span><br/>
            <label>]] .. self.translator:get("Adjust angle") .. [[</label><span> ]] .. key("lalt") .. [[ + ]] .. key("up") .. [[ / ]] .. key("down") .. [[</span><br/>
            <b>]] .. self.translator:get("Miscellaneous") .. [[</b>
            <label>]] .. self.translator:get("Hide help") .. [[</label><span> ]] .. key("option9") .. [[</span><br/>
            </div>
            <small class="version">]] .. self.translator:get("Version %s", self.version) .. [[ - &copy; Leniver</small>]],
        }
    else
        return {
            style = [[
            .help {
            font-size: 12px;
            height: 50px;
            left: 10px;
            top: 5px;
            position: absolute;
            width: 200px;
        }
            .version{
            bottom: 5px;
            font-size: 10px;
            position: fixed;
            right: 100px;
        }

            ]],
            html = [[
            <div class="help">
            ]] .. self.translator:get("Show help: %s", self.system.getActionKeyName("option9")) .. [[<br/>
            </div>
            <small class="version">]] .. self.translator:get("Version %s", self.version) .. [[ - &copy; Leniver</small>]],
        }
    end
end


function Helper:onActionStart(action)
    if action == "option9" then
        self.open = not self.open
    end
end