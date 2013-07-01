// This program was compiled from OCaml by js_of_ocaml 1.3
function caml_raise_with_arg (tag, arg) { throw [0, tag, arg]; }
function caml_raise_with_string (tag, msg) {
  caml_raise_with_arg (tag, new MlWrappedString (msg));
}
function caml_invalid_argument (msg) {
  caml_raise_with_string(caml_global_data[4], msg);
}
function caml_array_bound_error () {
  caml_invalid_argument("index out of bounds");
}
function caml_str_repeat(n, s) {
  if (!n) { return ""; }
  if (n & 1) { return caml_str_repeat(n - 1, s) + s; }
  var r = caml_str_repeat(n >> 1, s);
  return r + r;
}
function MlString(param) {
  if (param != null) {
    this.bytes = this.fullBytes = param;
    this.last = this.len = param.length;
  }
}
MlString.prototype = {
  string:null,
  bytes:null,
  fullBytes:null,
  array:null,
  len:null,
  last:0,
  toJsString:function() {
    return this.string = decodeURIComponent (escape(this.getFullBytes()));
  },
  toBytes:function() {
    if (this.string != null)
      var b = unescape (encodeURIComponent (this.string));
    else {
      var b = "", a = this.array, l = a.length;
      for (var i = 0; i < l; i ++) b += String.fromCharCode (a[i]);
    }
    this.bytes = this.fullBytes = b;
    this.last = this.len = b.length;
    return b;
  },
  getBytes:function() {
    var b = this.bytes;
    if (b == null) b = this.toBytes();
    return b;
  },
  getFullBytes:function() {
    var b = this.fullBytes;
    if (b !== null) return b;
    b = this.bytes;
    if (b == null) b = this.toBytes ();
    if (this.last < this.len) {
      this.bytes = (b += caml_str_repeat(this.len - this.last, '\0'));
      this.last = this.len;
    }
    this.fullBytes = b;
    return b;
  },
  toArray:function() {
    var b = this.bytes;
    if (b == null) b = this.toBytes ();
    var a = [], l = this.last;
    for (var i = 0; i < l; i++) a[i] = b.charCodeAt(i);
    for (l = this.len; i < l; i++) a[i] = 0;
    this.string = this.bytes = this.fullBytes = null;
    this.last = this.len;
    this.array = a;
    return a;
  },
  getArray:function() {
    var a = this.array;
    if (!a) a = this.toArray();
    return a;
  },
  getLen:function() {
    var len = this.len;
    if (len !== null) return len;
    this.toBytes();
    return this.len;
  },
  toString:function() { var s = this.string; return s?s:this.toJsString(); },
  valueOf:function() { var s = this.string; return s?s:this.toJsString(); },
  blitToArray:function(i1, a2, i2, l) {
    var a1 = this.array;
    if (a1) {
      if (i2 <= i1) {
        for (var i = 0; i < l; i++) a2[i2 + i] = a1[i1 + i];
      } else {
        for (var i = l - 1; i >= 0; i--) a2[i2 + i] = a1[i1 + i];
      }
    } else {
      var b = this.bytes;
      if (b == null) b = this.toBytes();
      var l1 = this.last - i1;
      if (l <= l1)
        for (var i = 0; i < l; i++) a2 [i2 + i] = b.charCodeAt(i1 + i);
      else {
        for (var i = 0; i < l1; i++) a2 [i2 + i] = b.charCodeAt(i1 + i);
        for (; i < l; i++) a2 [i2 + i] = 0;
      }
    }
  },
  get:function (i) {
    var a = this.array;
    if (a) return a[i];
    var b = this.bytes;
    if (b == null) b = this.toBytes();
    return (i<this.last)?b.charCodeAt(i):0;
  },
  safeGet:function (i) {
    if (!this.len) this.toBytes();
    if ((i < 0) || (i >= this.len)) caml_array_bound_error ();
    return this.get(i);
  },
  set:function (i, c) {
    var a = this.array;
    if (!a) {
      if (this.last == i) {
        this.bytes += String.fromCharCode (c & 0xff);
        this.last ++;
        return 0;
      }
      a = this.toArray();
    } else if (this.bytes != null) {
      this.bytes = this.fullBytes = this.string = null;
    }
    a[i] = c & 0xff;
    return 0;
  },
  safeSet:function (i, c) {
    if (this.len == null) this.toBytes ();
    if ((i < 0) || (i >= this.len)) caml_array_bound_error ();
    this.set(i, c);
  },
  fill:function (ofs, len, c) {
    if (ofs >= this.last && this.last && c == 0) return;
    var a = this.array;
    if (!a) a = this.toArray();
    else if (this.bytes != null) {
      this.bytes = this.fullBytes = this.string = null;
    }
    var l = ofs + len;
    for (var i = ofs; i < l; i++) a[i] = c;
  },
  compare:function (s2) {
    if (this.string != null && s2.string != null) {
      if (this.string < s2.string) return -1;
      if (this.string > s2.string) return 1;
      return 0;
    }
    var b1 = this.getFullBytes ();
    var b2 = s2.getFullBytes ();
    if (b1 < b2) return -1;
    if (b1 > b2) return 1;
    return 0;
  },
  equal:function (s2) {
    if (this.string != null && s2.string != null)
      return this.string == s2.string;
    return this.getFullBytes () == s2.getFullBytes ();
  },
  lessThan:function (s2) {
    if (this.string != null && s2.string != null)
      return this.string < s2.string;
    return this.getFullBytes () < s2.getFullBytes ();
  },
  lessEqual:function (s2) {
    if (this.string != null && s2.string != null)
      return this.string <= s2.string;
    return this.getFullBytes () <= s2.getFullBytes ();
  }
}
function MlWrappedString (s) { this.string = s; }
MlWrappedString.prototype = new MlString();
function MlMakeString (l) { this.bytes = ""; this.len = l; }
MlMakeString.prototype = new MlString ();
function caml_blit_string(s1, i1, s2, i2, len) {
  if (len === 0) return;
  if (i2 === s2.last && s2.bytes != null) {
    var b = s1.bytes;
    if (b == null) b = s1.toBytes ();
    if (i1 > 0 || s1.last > len) b = b.slice(i1, i1 + len);
    s2.bytes += b;
    s2.last += b.length;
    return;
  }
  var a = s2.array;
  if (!a) a = s2.toArray(); else { s2.bytes = s2.string = null; }
  s1.blitToArray (i1, a, i2, len);
}
function caml_call_gen(f, args) {
  if(f.fun)
    return caml_call_gen(f.fun, args);
  var n = f.length;
  var d = n - args.length;
  if (d == 0)
    return f.apply(null, args);
  else if (d < 0)
    return caml_call_gen(f.apply(null, args.slice(0,n)), args.slice(n));
  else
    return function (x){ return caml_call_gen(f, args.concat([x])); };
}
function caml_create_string(len) {
  if (len < 0) caml_invalid_argument("String.create");
  return new MlMakeString(len);
}
function caml_js_from_array(a) { return a.slice(1); }
function caml_js_pure_expr (f) { return f(); }
function caml_js_var(x) { return eval(x.toString()); }
function caml_js_wrap_callback(f) {
  var toArray = Array.prototype.slice;
  return function () {
    var args = (arguments.length > 0)?toArray.call (arguments):[undefined];
    return caml_call_gen(f, args);
  }
}
function caml_make_vect (len, init) {
  var b = [0]; for (var i = 1; i <= len; i++) b[i] = init; return b;
}
function caml_ml_out_channels_list () { return 0; }
var caml_global_data = [0];
function caml_register_global (n, v) { caml_global_data[n + 1] = v; }
var caml_named_values = {};
function caml_register_named_value(nm,v) {
  caml_named_values[nm] = v; return 0;
}
(function()
   {function _ag_(_bI_,_bJ_)
     {return _bI_.length==1?_bI_(_bJ_):caml_call_gen(_bI_,[_bJ_]);}
    var
     _a_=[0,new MlString("Invalid_argument")],
     _b_=[0,new MlString("Assert_failure")];
    caml_register_global(6,[0,new MlString("Not_found")]);
    caml_register_global(5,[0,new MlString("Division_by_zero")]);
    caml_register_global(3,_a_);
    caml_register_global(2,[0,new MlString("Failure")]);
    var
     _ab_=new MlString("Pervasives.do_at_exit"),
     _aa_=new MlString("String.sub"),
     _$_=new MlString("textarea"),
     ___=new MlString("input"),
     _Z_=new MlString("[oclosure]goog.events[/oclosure]"),
     _Y_=new MlString("[oclosure]goog.editor.Field[/oclosure]"),
     _X_=new MlString("delayedchange"),
     _W_=
      new MlString("[oclosure]goog.editor.plugins.HeaderFormatter[/oclosure]"),
     _V_=new MlString("[oclosure]goog.editor.plugins.LoremIpsum[/oclosure]"),
     _U_=new MlString("[oclosure]goog.editor.plugins.EnterHandler[/oclosure]"),
     _T_=
      new
       MlString
       ("[oclosure]goog.editor.plugins.BasicTextFormatter[/oclosure]"),
     _S_=
      new
       MlString
       ("[oclosure]goog.editor.plugins.RemoveFormatting[/oclosure]"),
     _R_=new MlString("[oclosure]goog.editor.plugins.UndoRedo[/oclosure]"),
     _Q_=
      new
       MlString
       ("[oclosure]goog.editor.plugins.SpacesTabHandler[/oclosure]"),
     _P_=
      new MlString("[oclosure]goog.editor.plugins.ListTabHandler[/oclosure]"),
     _O_=new MlString("[oclosure]goog.editor.plugins.LinkBubble[/oclosure]"),
     _N_=
      new
       MlString
       ("[oclosure]goog.editor.plugins.LinkDialogPlugin[/oclosure]"),
     _M_=new MlString("+undo"),
     _L_=new MlString("+redo"),
     _K_=new MlString("+link"),
     _J_=new MlString("+indent"),
     _I_=new MlString("+outdent"),
     _H_=new MlString("+removeFormat"),
     _G_=new MlString("+strikeThrough"),
     _F_=new MlString("+subscript"),
     _E_=new MlString("+superscript"),
     _D_=new MlString("+underline"),
     _C_=new MlString("+bold"),
     _B_=new MlString("+italic"),
     _A_=new MlString("+fontSize"),
     _z_=new MlString("+fontName"),
     _y_=new MlString("+foreColor"),
     _x_=new MlString("+backColor"),
     _w_=new MlString("+insertOrderedList"),
     _v_=new MlString("+insertUnorderedList"),
     _u_=new MlString("+justifyCenter"),
     _t_=new MlString("+justifyRight"),
     _s_=new MlString("+justifyLeft"),
     _r_=new MlString("[oclosure]goog.ui.editor.ToolbarController[/oclosure]"),
     _q_=new MlString("[oclosure]goog.ui.editor.DefaultToolbar[/oclosure]"),
     _p_=new MlString("fieldContents"),
     _o_=[0,new MlString("test_editor.ml"),71,14],
     _n_=new MlString("fieldContents"),
     _m_=[0,new MlString("test_editor.ml"),5,14],
     _l_=[0,new MlString("test_editor.ml"),2,52],
     _k_=new MlString("editMe"),
     _j_=new MlString("Click here to edit"),
     _i_=new MlString("toolbar"),
     _h_=new MlString("setFieldContent_b");
    function _g_(_f_)
     {var _c_=caml_ml_out_channels_list(0);
      for(;;)
       {if(_c_){var _d_=_c_[2];try {}catch(_e_){}var _c_=_d_;continue;}
        return 0;}}
    caml_register_named_value(_ab_,_g_);
    var _ac_=[0,0],_ad_=null,_ai_=undefined;
    function _ah_(_ae_,_af_){return _ae_==_ad_?_ag_(_af_,0):_ae_;}
    var _aj_=false,_al_=Array;
    function _am_(_ak_)
     {return _ak_ instanceof _al_?0:[0,new MlWrappedString(_ak_.toString())];}
    _ac_[1]=[0,_am_,_ac_[1]];
    function _ao_(_an_){return _an_;}
    var _ap_=this,_aq_=_ap_.document;
    this.HTMLElement===_ai_;
    function _au_(_ar_,_as_)
     {var _at_=_ar_.toString();
      return _as_.tagName.toLowerCase()===_at_?_ao_(_as_):_ad_;}
    function _aB_(_av_){return _av_;}
    function _aC_(_aw_)
     {return caml_js_pure_expr
              (function(_aA_)
                {var _ax_=_aw_.getLen()-21|0,_ay_=10;
                 if(0<=_ay_&&0<=_ax_&&!((_aw_.getLen()-_ax_|0)<_ay_))
                  {var _az_=caml_create_string(_ax_);
                   caml_blit_string(_aw_,_ay_,_az_,0,_ax_);
                   return caml_js_var(_az_);}
                 throw [0,_a_,_aa_];});}
    var _aD_=_aC_(_Z_),_aH_=_aC_(_Y_);
    function _aG_(_aE_,_aF_){return _aE_.registerPlugin(_aF_);}
    var
     _aI_=_X_.toString(),
     _aJ_=_aC_(_W_),
     _aK_=_aC_(_V_),
     _aL_=_aC_(_U_),
     _aM_=_aC_(_T_),
     _aN_=_aC_(_S_),
     _aO_=_aC_(_R_),
     _aP_=_aC_(_Q_),
     _aQ_=_aC_(_P_),
     _aR_=_aC_(_O_),
     _aS_=_aC_(_N_),
     _bb_=_M_.toString(),
     _ba_=_L_.toString(),
     _a$_=_K_.toString(),
     _a__=_J_.toString(),
     _a9_=_I_.toString(),
     _a8_=_H_.toString(),
     _a7_=_G_.toString(),
     _a6_=_F_.toString(),
     _a5_=_E_.toString(),
     _a4_=_D_.toString(),
     _a3_=_C_.toString(),
     _a2_=_B_.toString(),
     _a1_=_A_.toString(),
     _a0_=_z_.toString(),
     _aZ_=_y_.toString(),
     _aY_=_x_.toString(),
     _aX_=_w_.toString(),
     _aW_=_v_.toString(),
     _aV_=_u_.toString(),
     _aU_=_t_.toString(),
     _aT_=_s_.toString(),
     _bc_=_aC_(_r_),
     _bk_=_aC_(_q_);
    function _bh_(_bd_)
     {function _bf_(_be_){_ap_.alert(_bd_.toString());throw [0,_b_,_l_];}
      return _ah_(_aq_.getElementById(_bd_.toString()),_bf_);}
    function _bl_(_bi_)
     {function _bj_(_bg_){throw [0,_b_,_m_];}
      return _ah_(_au_(_$_,_bh_(_bi_)),_bj_);}
    var _bm_=new _aH_(_k_.toString(),_ad_);
    function _bp_(_bo_)
     {var _bn_=_bl_(_n_);return _bn_.value=_bm_.getCleanContents();}
    _aG_(_bm_,new _aM_());
    _aG_(_bm_,new _aN_());
    _aG_(_bm_,new _aO_(_ad_));
    _aG_(_bm_,new _aQ_());
    _aG_(_bm_,new _aP_());
    _aG_(_bm_,new _aL_());
    _aG_(_bm_,new _aJ_());
    _aG_(_bm_,new _aK_(_j_.toString()));
    _aG_(_bm_,new _aS_());
    _aG_(_bm_,new _aR_(caml_js_from_array([0])));
    var
     _bq_=
      [0,
       _a3_,
       _a2_,
       _a4_,
       _aZ_,
       _aY_,
       _a0_,
       _a1_,
       _a$_,
       _bb_,
       _ba_,
       _aW_,
       _aX_,
       _a__,
       _a9_,
       _aT_,
       _aV_,
       _aU_,
       _a6_,
       _a5_,
       _a7_,
       _a8_],
     _br_=_bq_.length-1;
    if(0===_br_)
     var _bs_=[0];
    else
     {var _bt_=caml_make_vect(_br_,_aB_(_bq_[0+1])),_bu_=1,_bv_=_br_-1|0;
      if(!(_bv_<_bu_))
       {var _bw_=_bu_;
        for(;;)
         {_bt_[_bw_+1]=_aB_(_bq_[_bw_+1]);
          var _bx_=_bw_+1|0;
          if(_bv_!==_bw_){var _bw_=_bx_;continue;}
          break;}}
      var _bs_=_bt_;}
    var _by_=caml_js_from_array(_bs_);
    new _bc_(_bm_,_bk_.makeToolbar(_by_,_bh_(_i_),_ad_));
    _aD_.listen(_aB_(_bm_),_aI_,caml_js_wrap_callback(_bp_),_ad_);
    _bm_.makeEditable(_ad_);
    function _bA_(_bz_){throw [0,_b_,_o_];}
    var _bD_=_ah_(_au_(___,_bh_(_h_)),_bA_);
    function _bC_(_bB_)
     {_bm_.setHtml(_aj_,_ao_(_bl_(_p_).value),_ad_,_ad_);return _aj_;}
    _bD_.onclick=
    _ao_
     (caml_js_wrap_callback
       (function(_bE_)
         {if(_bE_)
           {var _bF_=_bC_(_bE_);
            if(!(_bF_|0))_bE_.preventDefault();
            return _bF_;}
          var _bG_=event,_bH_=_bC_(_bG_);
          _bG_.returnValue=_bH_;
          return _bH_;}));
    _bp_(0);
    _g_(0);
    return;}
  ());
