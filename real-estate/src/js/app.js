App = {
  web3Provider: null,
  contracts: {},
	
  init: function() {

    $.getJSON('../real-estate.json',function(data){
      var list = $('#list');
      var template = $('#template');

      for( i =0; i< data.length;i++){
        template.find('img').attr('src',data[i].picture);
        template.find('.id').text(data[i].id);
        template.find('.type').text(data[i].type);
        template.find('.area').text(data[i].area);
        template.find('.price').text(data[i].price);
        
        list.append(template.html());
        
      }
    })
   
  },

  initWeb3: function() {
	
  },

  initContract: function() {
		
  },

  buyRealEstate: function() {	

  },

  loadRealEstates: function() {
	
  },
	
  listenToEvents: function() {
	
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
