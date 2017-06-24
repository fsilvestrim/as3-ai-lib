/**
 * Created with IntelliJ IDEA.
 * User: filipesilvestrim
 * Date: 21/01/14
 * Time: 21:34
 * To change this template use File | Settings | File Templates.
 */
package com.filipesilvestrim.ai.fsm {
import avmplus.getQualifiedClassName;

import com.filipesilvestrim.ai.fsm.IState;

import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getTimer;

public class StateMachine {
    private var _seq    : Array = new Array();
    private var _all    : Dictionary = new Dictionary();
    private var _curr   : IState = null;
    private var _prev   : IState = null;
    private var _next   : IState = null;

    public var paused   : Boolean = false;
    public var exit     : Function = null;
    public var change   : Function = null;
    public var error    : Function = null;


    private function get cIdx():int { return _seq.indexOf(_curr); }
    public function get curr():IState { return _curr; }
    public function get prev():IState { return _prev; }
    public function get next():IState { return _next || _all[Math.min(cIdx+1, _seq.length-1)]; }

    final public function nextState (iState:Class)  : void { _next = _all[iState]; }
    public function update()                        : void { if(!paused && _curr != null) _curr.update(getTimer()); }

    final private function changeTo (next:IState)   : void {
        if (next == null) {
            return;
        }

        if(_curr != null) {
            if(next.allowedFrom != null && Class(getDefinitionByName(getQualifiedClassName(_curr))) in next.allowedFrom) {
                if(error != null)   error(new Error('State not allowed!'));
                else                return;
            }

            (_prev = _curr).exit(getTimer());

            if(exit != null) exit(_prev);
        }

        trace(this, " changing state from ", _curr, " to ", next);

        (_curr = next).enter(getTimer());

        if(change!=null) change(_curr);
    }

    final public function changeTo (iState:Class)   : void { private::changeTo(_all[iState]); }

    final public function gotoPrev()                : void { private::changeTo(prev); }
    final public function gotoNext()                : void { private::changeTo(next); }

    final public function registerClass(iState:Class,...args)  : void { _all[iState] = new iState(); (_all[iState] as IState).register.apply(null,[this].concat(args)); _seq.push(_all[iState]); }
    final public function registerInstance(inst:IState, iState:Class, ...args)  : void { _all[iState] = inst; inst.register.apply(null,[this].concat(args)); _seq.push(_all[iState]);}
}
}
