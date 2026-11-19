// layui 的模块工厂全部内联打包在 layui/layui.js 里（dist 版本内置 layui.all，
// 不会再去请求 modules/*.js），但模块要经 layui.use 才会实例化。
//
// element 负责 layui-nav 的下拉展开与 .layui-nav-bar 滑块；
// form 负责把原生 select / checkbox / radio 换成 layui 皮肤。
// 这里显式再 render 一次，不依赖模块加载时是否自动渲染静态表单。
//
// 页面级脚本请写在视图的 content_for(:page_scripts) 里，不要堆到这个文件。
layui.use([ "element", "form" ], function () {
  layui.form.render();
});
