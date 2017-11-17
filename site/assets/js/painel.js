$(function () {

    $('form').each(function(){
        $(this).validate({
            errorClass: 'error-form'
        });
    });

    jQuery('#forget-password').click(function() {
        jQuery('.login-form').hide();
        jQuery('.forget-form').show();
    });

    jQuery('#back-btn').click(function() {
        jQuery('.login-form').show();
        jQuery('.forget-form').hide();
    });

    $("input[name='id']").parent().parent().hide();

    $('.excluir').click(function () {

        var href = $(this).attr('href');

        swal({
                title: "Deseja excluir este registro?",
                text: "Após a exclusão você não poderá mais acessá-lo.",
                type: "error",
                showCancelButton: true,
                confirmButtonClass: "btn-danger",
                confirmButtonText: "Sim",
                cancelButtonText: "Cancelar",
                closeOnConfirm: false
            },
            function(){
                window.location.replace(href);
            });
        //$('#confirmarexclusao').attr('href', href);
        //$('#modalExcluir').modal('show');
        return false;
    })

})