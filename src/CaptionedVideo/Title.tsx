import {fitText} from '@remotion/layout-utils';
import {useVideoConfig} from 'remotion';

import {AbsoluteFill} from 'remotion';

import {TheBoldFont} from '../load-font';

const fontFamily = TheBoldFont;
const Title = ({text}: {text: string}) => {
	const {width} = useVideoConfig();
	const desiredFontSize = 120;

	const fittedText = fitText({
		fontFamily,
		text,
		withinWidth: width * 0.8,
	});

	const fontSize = Math.min(desiredFontSize, fittedText.fontSize);

	return (
		<>
			<AbsoluteFill
				style={{
					justifyContent: 'flex-start',
					alignItems: 'center',
					top: 300,
					pointerEvents: 'none',
				}}
			>
				<div
					style={{
						fontSize,
						color: 'white',
						fontFamily,
						textTransform: 'uppercase',
						textAlign: 'center',
						padding: '10px',
						maxWidth: '90%',
					}}
				>
					{text}
				</div>
			</AbsoluteFill>
		</>
	);
};

export default Title;
