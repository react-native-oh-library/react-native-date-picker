import type { ViewProps } from "react-native/Libraries/Components/View/ViewPropTypes";
import type { HostComponent } from "react-native";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";
import type {
    Float,
    WithDefault,
    BubblingEventHandler,
    Double,
  } from 'react-native/Libraries/Types/CodegenTypes';
  type DateEvent = {
    timestamp: Double
  }
export interface NativeProps extends ViewProps {
    text?: string
    mode?: WithDefault<'date' | 'time' | 'datetime', 'datetime'>
    maximumDate?: Double
    minimumDate?: Double
    onChange?: BubblingEventHandler<DateEvent>,
    onConfirm?: BubblingEventHandler<DateEvent>,
    onCancel?: BubblingEventHandler<undefined>,
 // 添加其它 props
}
export default codegenNativeComponent<NativeProps>("NativeDatePickerView") as HostComponent<NativeProps>;