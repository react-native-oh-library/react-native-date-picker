import type { ViewProps } from "react-native/Libraries/Components/View/ViewPropTypes"; 
import type { HostComponent } from "react-native"; 
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent"; 
import type {
    Float,
    WithDefault,
    BubblingEventHandler,
    Double,
  } from 'react-native/Libraries/Types/CodegenTypes'
  type DateEven  = Readonly<{
    timestamp:string
  }
  >
export interface NativeProps extends ViewProps {   
    mode?: WithDefault<'date' | 'datetime' | 'time','date' >;
    date?: string
    open?: boolean
    modal?:boolean
    onConfirm?:BubblingEventHandler<DateEven>;
    onDateChange?:BubblingEventHandler<DateEven>;
    onChange?:BubblingEventHandler<DateEven>;
    onCancel?:BubblingEventHandler<undefined>;
    maximumDate?: string
    minimumDate?: string
} 
 
export default codegenNativeComponent<NativeProps>("NativeDatePickerView") as HostComponent<NativeProps>; 