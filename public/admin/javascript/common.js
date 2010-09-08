var tags = {
  _post_id: 0,
  init : function(post_id){
    this._post_id = post_id || 0;
    this.get_tags();
    // add a tag
    this.add_tag();
  }, 
  get_tags: function() {
    $.get(lennon.blog_url+"/admin/tags/"+this._post_id+"/ajax", function(data){
      $('#tags_list')
        .html(data)
        .removeClass('loading');
    });
  },
  add_tag : function(){
    var self = this;
    $('#tag_ajax_form_submit').click(function(){
      $('#tags_list').addClass('loading');
      var tag_name = $('#tag_ajax_form_name').val();
      $.post(lennon.blog_url+"/admin/tags/add", {name: tag_name}, function(){
        $('#tags_list').removeClass('loading');
        self.get_tags(this._post_id);
        $('#tag_ajax_form_name').val('');
      });
      return false;
    })
  }
};

var post_date = {
  _post_id : 0,
  init: function(post_id) {
    this._post_id = post_id || 0;
  }
};