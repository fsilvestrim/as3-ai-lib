/**
 * Created with IntelliJ IDEA.
 * User: filipesilvestrim
 * Date: 21/01/14
 * Time: 21:31
 * To change this template use File | Settings | File Templates.
 */
package com.filipesilvestrim.ai.fsm {
public interface IState {
    function get allowedFrom()  : Vector.<Class>;
    function register(ref:StateMachine, ...args) : void;
    function enter(time:int)    : void;
    function exit(time:int)     : void;
    function update(time:int)   : void;
}
}
