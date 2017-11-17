$(function () {

    $('.bxslider').bxSlider({
        controls: false
    });
    $('[data-toggle="tooltip"]').tooltip();

    $('.delete').click(function(){
        if(!confirm('Are you sure you want to delete this project?')){
            return false;
        };
    });

    $('.deletesharing').click(function(){
        if(!confirm('Are you sure you want to remove this sharing?')){
            return false;
        };
    });

    $('.btn-collapse').click(function(){
        $('.collapse.in')
            .collapse('hide');
    });

    /*var dataTabele = $('.dataTable').DataTable({
        dom: 'Bfrtip',
        buttons: [
            'copy', 'csv', 'excel', 'pdf', 'print'
        ]
    });*/

    $('.form-validate').validate();

    $( "form" ).submit(function(){
        //$('.modal-loading').modal({backdrop: 'static', keyboard: false})
    });

    $( ".loading" ).click(function(){
        $('.modal-loading').modal({backdrop: 'static', keyboard: false})

    });


})