/**
 * Created with IntelliJ IDEA.
 * User: filipesilvestrim
 * Date: 21/01/14
 * Time: 21:34
 * To change this template use File | Settings | File Templates.
 */
package com.filipesilvestrim.ai.fsm {
import avmplus.getQualifiedClassName;

import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getTimer;

public class StateMachine {
    private var _all    : Dictionary = new Dictionary();
    private var _curr   : IState = null;
    private var _prev   : IState = null;
    private var _next   : IState = null;

    public var paused   : Boolean = false;
    public var exit     : Function = null;
    public var change   : Function = null;
    public var error    : Function = null;


    public function get curr():IState { return _curr; }
    public function get prev():IState { return _prev; }
    public function get next():IState { return _next; }

    public function nextState (iState:Class)    : void { _next = _all[iState]; }
    public function update()                    : void { if(!paused && _curr != null) _curr.update(getTimer()); }

    private function changeTo (next:IState)     : void { if(next.allowedFrom.indexOf(Class(getDefinitionByName(getQualifiedClassName(_curr))))==-1) { if(error != null) error(new Error('State not allowed!')) else return;};  if(_curr != null) { IState(_prev = _curr).exit(getTimer()); if(exit != null) exit(_prev); } ((_curr = next) as IState).enter(getTimer()); if(change!=null) change(_curr); }
    public function changeTo (iState:Class)     : void { private::changeTo(_all[iState]); }

    public function gotoPrev()                  : void { private::changeTo(_prev); }
    public function gotoNext()                  : void { private::changeTo(_next); }

    public function register(iState:Class,...args)  : void { _all[iState] = new iState(); (_all[iState] as IState).register.apply(null,[this].concat(args)); }
}
}
