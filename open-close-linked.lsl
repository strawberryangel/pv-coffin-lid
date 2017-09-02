// Open/close linked doors using time-based calculations.
//

//#include "lib/debug.lsl"
//#include "lib/profiling.lsl"
//#include "door-script/lib/configure.lsl"
//#include "door-script/lib/messages.lsl"


////////////////////////////////////////////////////////////////////////////////
//
// These items need to be configured.
//
////////////////////////////////////////////////////////////////////////////////

integer configured = FALSE;         // Has this been configured?

float angle_multiplier;             // 1 or -1, depending on angle.
vector object_center = <0, 0, 0>;   // Object center in terms of rotation axis.
float open_time;                    // Number of seconds spent opening.
float open_angle;                   // How far to  open the door.
vector rotation_axis = <0, 0, 1>;   // Default to Z axis.

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// Assumption: The location of the door doesn't move 
// from the time that the door is opened until it is closed. 
// Store the current position and location of the door
// so we can restore it when the door is closed again. 
vector closed_position;
rotation closed_rotation;
vector open_position;
rotation open_rotation;
integer link_number;

post_config()
{
}

get_parameters(string config)
{
    configured = TRUE;

    angle_multiplier = 1;
    object_center = <0.13,0,0.012>;
    open_time = 1.5;
    open_angle = 110;
    rotation_axis = <0,1,0.018>;
}

////////////////////////////////////////////////////////////////////////////////
//
// Door Actions
//
////////////////////////////////////////////////////////////////////////////////

move_door(integer is_opening)
{
    llSetLinkPrimitiveParamsFast(link_number, [
        PRIM_PHANTOM, TRUE
    ]);
    
    integer iterations = 0;

    // Vector with units in radians per second.
    float rotation_rate = 
        (angle_multiplier * open_angle * DEG_TO_RAD / open_time);

    llResetTime();
    float current_time = llGetTime();
    float angle;
    while (current_time < open_time) {
        // Get rotation for this iteration.
        if(is_opening)
            angle = rotation_rate * current_time;
        else 
            angle = rotation_rate * (open_time - current_time);
            
        // We have the axis of rotation and the angle. 
        // Compose the quaternion that describes this rotation.
        rotation q = llAxisAngle2Rot(rotation_axis, angle);
        // Convert it to the local rotation 
        // q' = closed_rotation * q  --- remember that SL reverses the operands.
        rotation current_rotation = q * closed_rotation;

        llSetLinkPrimitiveParamsFast(link_number, [
            PRIM_ROT_LOCAL, current_rotation,
            PRIM_POS_LOCAL, position(angle)
        ]);

        current_time = llGetTime();
        ++iterations;
    }

    //debug("Door movement iterations: " + (string)iterations);
}

move_door_finalize(vector target_position, rotation target_rotation)
{
    // Final rotation. Force it into place to avoid rounding error, etc. 
    llSetLinkPrimitiveParamsFast(link_number, [
        PRIM_ROT_LOCAL, target_rotation,
        PRIM_POS_LOCAL, target_position,
        PRIM_PHANTOM, FALSE
    ]);
}

close_door_start()
{

    //debug("The door is closing");
    
    move_door(FALSE);
}

close_door_finalize()
{
    move_door_finalize(closed_position, closed_rotation);
}

open_door_start()
{
    // Remember these positions.
    link_number = llGetLinkNumber();
    closed_position = llGetLocalPos();
    closed_rotation = llGetLocalRot();
    open_position = closed_position;
    //debug("closed_position " + (string)(closed_position));
    //debug("closed_rotation " + (string)(closed_rotation));

    float angle = angle_multiplier * open_angle * DEG_TO_RAD;
    rotation q = llAxisAngle2Rot(rotation_axis, angle);
    open_rotation = q * closed_rotation;
    open_position = position(angle);
    
    //debug("The door is opening");
    move_door(TRUE);
}

open_door_finalize()
{
    move_door_finalize(open_position, open_rotation);
}

vector position(float angle)
{
    rotation q = llAxisAngle2Rot(rotation_axis, angle);
    vector result = closed_position 
        + (object_center - object_center * q) * closed_rotation;

    return result;
}

default // configuration
{
    state_entry()
    {
        llSetMemoryLimit(327268);
        //debug_prefix = llGetScriptName();
        //DEBUG = DEBUG_STYLE_OWNER;
        
        // Copied from the wiki. Without this, the script throws errors.
        llSetLinkPrimitiveParamsFast(LINK_THIS,
            [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_NONE]);

        get_parameters(llGetObjectDesc());
        if(configured)
        {
            //describe_configuration();
            state closed_state;
        }
        //else
            //debug("Not confugred.");
    }
}

state closed_state
{
    state_entry()
    {
        //debug("The door is now closed.");
    }
    
    touch_start(integer index)
    {
        //start_profiling();
        open_door_start();
        open_door_finalize();
        //stop_profiling();
        state open_state;
    }
}

state open_state
{
    state_entry()
    {
        //debug("The door is now open.");
    }
    
    touch_start(integer index)
    {
        //start_profiling();
        close_door_start();
        close_door_finalize();
        //stop_profiling();
        state closed_state;
    }
}
