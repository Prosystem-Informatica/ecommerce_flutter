import 'package:bloc/bloc.dart';
import '../../../../../repositories/product/i_consult_product_repository.dart';
import 'consult_product_bloc_state.dart';

class ConsultProductBlocCubit extends Cubit<ConsultProductBlocState> {
  final IConsultProductRepository productRepository;

  ConsultProductBlocCubit({required this.productRepository})
      : super(ConsultProductBlocState.initial());

  Future<void> fetchProducts() async {
    try {
      emit(state.copyWith(status: ConsultProductStateStatus.loading));

      final data = await productRepository.getProducts();

      emit(state.copyWith(
        status: ConsultProductStateStatus.success,
        products: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ConsultProductStateStatus.error,
        errorMessage: 'Erro ao carregar produtos',
      ));
    }
  }
}
